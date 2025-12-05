#!/usr/bin/env python3
"""
False Friends Expansion Script

This script helps expand the false friends database by:
1. Converting the Matsushita JCKV database (Excel) to our JSON format
2. Auto-detecting potential false friends by comparing JMDict vs CEDICT
3. Merging with our curated entries (preserving examples/mnemonics)

Usage:
    python expand_false_friends.py --jckv path/to/JCKV.xlsx
    python expand_false_friends.py --auto-detect
    python expand_false_friends.py --merge

Output:
    output/false_friends_expanded.json
"""

import json
import re
import os
from pathlib import Path
from dataclasses import dataclass, asdict, field
from typing import Optional, List
from collections import defaultdict

try:
    import openpyxl
    HAS_OPENPYXL = True
except ImportError:
    HAS_OPENPYXL = False
    print("Note: Install openpyxl for Excel support: pip install openpyxl")


# =============================================================================
# Data Models
# =============================================================================

@dataclass
class FalseFriend:
    id: str
    characters: str
    type: int  # 1-4 classification
    category: str  # true_divergence, simplification_merge, etc.
    severity: str  # critical, important, subtle
    affects: str  # both, simplified_only, traditional_only

    jp_reading: str
    jp_meanings: List[str]
    jp_example: str = ""
    jp_example_translation: str = ""

    cn_pinyin: str = ""
    cn_characters: str = ""  # Chinese simplified form if different from JP
    cn_meanings_simplified: List[str] = field(default_factory=list)
    cn_meanings_traditional: List[str] = field(default_factory=list)
    cn_example: str = ""
    cn_example_translation: str = ""

    explanation: str = ""
    mnemonic_tip: str = ""
    traditional_note: str = ""
    merged_from: List[str] = field(default_factory=list)

    # Structured meanings from JCKV
    shared_meanings: List[str] = field(default_factory=list)
    jp_only_meanings: List[str] = field(default_factory=list)
    cn_only_meanings: List[str] = field(default_factory=list)

    # Metadata
    source: str = "auto"  # curated, jckv, auto
    confidence: float = 1.0
    needs_review: bool = False


# =============================================================================
# JCKV Database Converter
# =============================================================================

def parse_meaning_text(text: str) -> str:
    """Clean up meaning text - strip labels and whitespace."""
    if not text or text == 'nan':
        return ""
    # Remove trailing newlines and whitespace
    return text.strip()


def convert_jckv_database(excel_path: str) -> List[FalseFriend]:
    """
    Convert Matsushita JCKV (日中対照漢字語データベース) v3.0 to FalseFriend objects.

    The JCKV database uses these patterns in the Ver.3.0 意味対応 column:
    - ＝ (同形同義): Same meaning - SKIP
    - φ (非同形): No Chinese equivalent - SKIP
    - ＞ (JP has extra meanings): type 1, severity "important"
    - ＜ (CN has extra meanings): type 2, severity "important"
    - ＞＜ (Both have unique meanings): type 3, severity "important"
    - ≠ (Completely different meanings): type 4, severity "critical"

    Column mapping from JKVC_ver3_0.xlsx:
    - Col 2: 見出し語彙素 (headword/kanji) → characters (PRIMARY)
    - Col 3: 標準的(新聞)表記 (standard writing, may be hiragana) → fallback only
    - Col 5: 標準的読み方（カタカナ）→ jp_reading
    - Col 8: 中国語表記 → cn_characters (Chinese simplified form)
    - Col 9: 中国語ピンイン表記 → cn_pinyin
    - Col 10: Ver.3.0 意味対応 → pattern
    - Col 13: 日本語と中国語に共通の意味 → shared_meanings
    - Col 15: 日本語のみに存在する意味 → jp_only_meanings
    - Col 17: 中国語のみに存在する意味 → cn_only_meanings
    """
    if not HAS_OPENPYXL:
        raise ImportError("openpyxl required: pip install openpyxl")

    wb = openpyxl.load_workbook(excel_path, read_only=True)
    ws = wb.active

    false_friends = []
    stats = {'＞': 0, '＜': 0, '＞＜': 0, '≠': 0, 'skipped_same': 0, 'skipped_no_cn': 0, 'hiragana_only': 0}

    # Column indices (0-based) based on actual JCKV structure
    COL_HEADWORD = 2        # 見出し語彙素 (kanji headword) - USE THIS FIRST
    COL_STANDARD = 3        # 標準的(新聞)表記 (may be hiragana) - FALLBACK ONLY
    COL_READING = 5         # 標準的読み方（カタカナ）
    COL_CN_CHARS = 8        # 中国語表記 (Chinese simplified characters)
    COL_PINYIN = 9          # 中国語ピンイン表記
    COL_PATTERN = 10        # Ver.3.0 意味対応
    COL_SHARED_MEANING = 13 # 日本語と中国語に共通の意味（日本語記述）
    COL_JP_ONLY = 15        # 日本語のみに存在する意味
    COL_CN_ONLY = 17        # 中国語のみに存在する意味

    # Pattern mapping
    PATTERN_MAP = {
        '＞': {'type': 1, 'severity': 'important', 'category': 'scope_difference'},    # JP has extra
        '＜': {'type': 2, 'severity': 'important', 'category': 'scope_difference'},    # CN has extra
        '＞＜': {'type': 3, 'severity': 'important', 'category': 'scope_difference'},  # Both have extra
        '≠': {'type': 4, 'severity': 'critical', 'category': 'true_divergence'},       # Different
    }

    # Skip header row
    rows = list(ws.iter_rows(min_row=2, values_only=True))
    print(f"Processing {len(rows)} rows from JCKV...")

    entry_num = 0
    for row_idx, row in enumerate(rows, start=2):
        try:
            # Skip empty rows
            if not row or len(row) <= COL_PATTERN:
                continue

            pattern = str(row[COL_PATTERN] or '').strip()

            # Skip same meaning (＝) and no Chinese equivalent (φ)
            if pattern == '＝':
                stats['skipped_same'] += 1
                continue
            if pattern == 'φ':
                stats['skipped_no_cn'] += 1
                continue

            # Only process our target patterns
            if pattern not in PATTERN_MAP:
                continue

            # Extract data - prioritize kanji headword over standard form
            headword = str(row[COL_HEADWORD] or '').strip()
            standard_form = str(row[COL_STANDARD] or '').strip()
            reading = str(row[COL_READING] or '').strip()
            cn_chars = str(row[COL_CN_CHARS] or '').strip()
            pinyin = str(row[COL_PINYIN] or '').strip()
            shared_meaning_raw = str(row[COL_SHARED_MEANING] or '').strip() if len(row) > COL_SHARED_MEANING else ''
            jp_only_raw = str(row[COL_JP_ONLY] or '').strip() if len(row) > COL_JP_ONLY else ''
            cn_only_raw = str(row[COL_CN_ONLY] or '').strip() if len(row) > COL_CN_ONLY else ''

            # IMPORTANT: Use kanji headword first, only fall back to standard form if empty
            # The standard form (標準的表記) is often hiragana, we want kanji (見出し語彙素)
            characters = headword if headword and headword != '--' else standard_form

            if not characters or characters == '--':
                continue

            # Track entries that only have hiragana (for statistics)
            if not headword or headword == '--':
                stats['hiragana_only'] += 1

            # Skip if no Chinese equivalent
            if cn_chars == '--' or not cn_chars:
                stats['skipped_no_cn'] += 1
                continue

            # Get pattern info
            pattern_info = PATTERN_MAP[pattern]
            entry_num += 1
            stats[pattern] += 1

            # Clean meaning texts (strip whitespace and 'nan')
            shared_meaning = parse_meaning_text(shared_meaning_raw)
            jp_only = parse_meaning_text(jp_only_raw)
            cn_only = parse_meaning_text(cn_only_raw)

            # Build Japanese meanings list (clean, no prefixes)
            jp_meanings = []
            if shared_meaning:
                jp_meanings.append(shared_meaning)
            if jp_only:
                jp_meanings.append(jp_only)

            # Build Chinese meanings list (clean, no prefixes)
            cn_meanings = []
            if shared_meaning:
                cn_meanings.append(shared_meaning)
            if cn_only:
                cn_meanings.append(cn_only)

            # Store structured meanings separately
            shared_meanings_list = [shared_meaning] if shared_meaning else []
            jp_only_meanings_list = [jp_only] if jp_only else []
            cn_only_meanings_list = [cn_only] if cn_only else []

            # Build explanation
            if pattern == '≠':
                explanation = f"Completely different meanings: JP '{jp_only}' vs CN '{cn_only}'"
            elif pattern == '＞':
                explanation = f"Japanese has additional meaning: {jp_only}"
            elif pattern == '＜':
                explanation = f"Chinese has additional meaning: {cn_only}"
            else:  # ＞＜
                explanation = f"Both languages have unique meanings. JP: {jp_only}; CN: {cn_only}"

            # Convert reading to formatted string
            jp_reading_formatted = reading if reading and reading != 'nan' else ""

            # Clean up pinyin (remove newlines, etc.)
            pinyin_clean = pinyin.replace('\n', ' ').strip() if pinyin and pinyin != 'nan' else ""

            # Store Chinese characters (may differ from Japanese due to simplification)
            cn_characters = cn_chars if cn_chars and cn_chars != '--' and cn_chars != characters else ""

            ff = FalseFriend(
                id=f"jckv_{entry_num:04d}",
                characters=characters,
                type=pattern_info['type'],
                category=pattern_info['category'],
                severity=pattern_info['severity'],
                affects="both",
                jp_reading=jp_reading_formatted,
                jp_meanings=jp_meanings if jp_meanings else [],
                cn_pinyin=pinyin_clean,
                cn_characters=cn_characters,
                cn_meanings_simplified=cn_meanings if cn_meanings else [],
                cn_meanings_traditional=cn_meanings if cn_meanings else [],
                explanation=explanation,
                shared_meanings=shared_meanings_list,
                jp_only_meanings=jp_only_meanings_list,
                cn_only_meanings=cn_only_meanings_list,
                source="jckv",
                confidence=0.9,
                needs_review=True
            )

            false_friends.append(ff)

        except Exception as e:
            print(f"Error processing row {row_idx}: {e}")
            continue

    # Print statistics
    print(f"\n=== JCKV Extraction Statistics ===")
    print(f"Total false friends extracted: {len(false_friends)}")
    print(f"  ≠ (completely different, critical): {stats['≠']}")
    print(f"  ＞ (JP has extra meanings, important): {stats['＞']}")
    print(f"  ＜ (CN has extra meanings, important): {stats['＜']}")
    print(f"  ＞＜ (both have unique, important): {stats['＞＜']}")
    print(f"Skipped:")
    print(f"  ＝ (same meaning): {stats['skipped_same']}")
    print(f"  φ/-- (no Chinese equivalent): {stats['skipped_no_cn']}")
    print(f"Notes:")
    print(f"  Entries with hiragana fallback (no kanji headword): {stats['hiragana_only']}")

    return false_friends


# =============================================================================
# Auto-Detection from JMDict + CEDICT
# =============================================================================

def load_jmdict_meanings(jmdict_path: str) -> dict:
    """Load Japanese meanings from processed JMDict."""
    meanings = {}
    # This would parse JMDict XML or our processed JSON
    # For now, return empty - implement based on your data pipeline output
    return meanings


def load_cedict_meanings(cedict_path: str) -> dict:
    """Load Chinese meanings from CC-CEDICT."""
    meanings = {}
    # This would parse CEDICT or our processed JSON
    return meanings


def compute_meaning_similarity(jp_meanings: List[str], cn_meanings: List[str]) -> float:
    """
    Compute similarity between Japanese and Chinese meanings.
    Returns 0.0 (completely different) to 1.0 (identical).
    """
    if not jp_meanings or not cn_meanings:
        return 0.5  # Unknown
    
    jp_words = set()
    for m in jp_meanings:
        jp_words.update(m.lower().split())
    
    cn_words = set()
    for m in cn_meanings:
        cn_words.update(m.lower().split())
    
    if not jp_words or not cn_words:
        return 0.5
    
    intersection = jp_words & cn_words
    union = jp_words | cn_words
    
    return len(intersection) / len(union) if union else 0.5


def auto_detect_false_friends(
    jmdict_path: str,
    cedict_path: str,
    threshold: float = 0.3
) -> List[FalseFriend]:
    """
    Automatically detect potential false friends by comparing meanings.
    
    Args:
        threshold: Maximum similarity to be considered a false friend (0-1)
    """
    jp_meanings = load_jmdict_meanings(jmdict_path)
    cn_meanings = load_cedict_meanings(cedict_path)
    
    candidates = []
    
    # Find shared characters/words
    shared = set(jp_meanings.keys()) & set(cn_meanings.keys())
    
    for word in shared:
        jp = jp_meanings[word]
        cn = cn_meanings[word]
        
        similarity = compute_meaning_similarity(jp, cn)
        
        if similarity < threshold:
            # Potential false friend
            severity = "critical" if similarity < 0.1 else "important" if similarity < 0.2 else "subtle"
            
            ff = FalseFriend(
                id=f"auto_{len(candidates):04d}",
                characters=word,
                type=4 if similarity < 0.1 else 3,
                category="true_divergence",
                severity=severity,
                affects="both",
                jp_reading="",
                jp_meanings=jp,
                cn_pinyin="",
                cn_meanings_simplified=cn,
                cn_meanings_traditional=cn,
                explanation=f"Auto-detected: meaning similarity {similarity:.2f}",
                source="auto",
                confidence=1.0 - similarity,
                needs_review=True
            )
            candidates.append(ff)
    
    # Sort by confidence (most different first)
    candidates.sort(key=lambda x: x.confidence, reverse=True)
    
    print(f"Auto-detected {len(candidates)} potential false friends")
    return candidates


# =============================================================================
# Merge Databases
# =============================================================================

def load_curated_false_friends(json_path: str) -> List[FalseFriend]:
    """Load our curated false friends."""
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    entries = data.get('false_friends', data)  # Handle both formats

    false_friends = []
    for entry in entries:
        ff = FalseFriend(
            id=entry['id'],
            characters=entry['characters'],
            type=entry.get('type', 4),
            category=entry.get('category', 'true_divergence'),
            severity=entry.get('severity', 'important'),
            affects=entry.get('affects', 'both'),
            jp_reading=entry.get('jp_reading', ''),
            jp_meanings=entry.get('jp_meanings', []),
            jp_example=entry.get('jp_example', ''),
            jp_example_translation=entry.get('jp_example_translation', ''),
            cn_pinyin=entry.get('cn_pinyin', ''),
            cn_characters=entry.get('cn_characters', ''),
            cn_meanings_simplified=entry.get('cn_meanings_simplified', entry.get('cn_meanings', [])),
            cn_meanings_traditional=entry.get('cn_meanings_traditional', entry.get('cn_meanings', [])),
            cn_example=entry.get('cn_example', ''),
            cn_example_translation=entry.get('cn_example_translation', ''),
            explanation=entry.get('explanation', ''),
            mnemonic_tip=entry.get('mnemonic_tip', ''),
            traditional_note=entry.get('traditional_note', ''),
            merged_from=entry.get('merged_from', []),
            shared_meanings=entry.get('shared_meanings', []),
            jp_only_meanings=entry.get('jp_only_meanings', []),
            cn_only_meanings=entry.get('cn_only_meanings', []),
            source='curated',
            confidence=1.0,
            needs_review=False
        )
        false_friends.append(ff)

    return false_friends


def merge_false_friends(
    curated: List[FalseFriend],
    jckv: List[FalseFriend],
    auto: List[FalseFriend]
) -> List[FalseFriend]:
    """
    Merge false friends from multiple sources.
    Priority: curated > jckv > auto
    """
    merged = {}
    
    # Add auto-detected first (lowest priority)
    for ff in auto:
        merged[ff.characters] = ff
    
    # Add JCKV (overwrites auto)
    for ff in jckv:
        if ff.characters in merged:
            # Keep some auto data if JCKV is missing it
            existing = merged[ff.characters]
            if not ff.jp_reading and existing.jp_reading:
                ff.jp_reading = existing.jp_reading
            if not ff.cn_pinyin and existing.cn_pinyin:
                ff.cn_pinyin = existing.cn_pinyin
        merged[ff.characters] = ff
    
    # Add curated (highest priority, overwrites everything)
    for ff in curated:
        merged[ff.characters] = ff
    
    # Sort by severity (critical first) then alphabetically
    severity_order = {'critical': 0, 'important': 1, 'subtle': 2}
    result = sorted(
        merged.values(),
        key=lambda x: (severity_order.get(x.severity, 3), x.characters)
    )
    
    print(f"Merged: {len(curated)} curated + {len(jckv)} JCKV + {len(auto)} auto = {len(result)} total")
    return result


def save_false_friends(false_friends: List[FalseFriend], output_path: str):
    """Save false friends to JSON in the format expected by the Swift app."""
    # Count statistics
    stats = {
        'total': len(false_friends),
        'by_severity': defaultdict(int),
        'by_source': defaultdict(int),
        'by_category': defaultdict(int),
        'needs_review': 0
    }

    for ff in false_friends:
        stats['by_severity'][ff.severity] += 1
        stats['by_source'][ff.source] += 1
        stats['by_category'][ff.category] += 1
        if ff.needs_review:
            stats['needs_review'] += 1

    # Categories dict expected by Swift FalseFriendsMetadata
    categories = {
        "true_divergence": "Meanings evolved differently over centuries in both languages",
        "simplification_merge": "Confusion exists because Simplified Chinese merged distinct Traditional characters",
        "japanese_coinage": "Word invented/repurposed in Meiji-era Japan, borrowed back to China",
        "scope_difference": "Same core meaning but different range of usage"
    }

    # Convert FalseFriend objects to dicts, excluding metadata fields not in Swift model
    def to_swift_dict(ff: FalseFriend) -> dict:
        d = asdict(ff)
        # Remove fields not in the Swift FalseFriend model
        d.pop('source', None)
        d.pop('confidence', None)
        d.pop('needs_review', None)
        return d

    output = {
        'metadata': {
            'version': '3.0',
            'description': 'Expanded false friends database',
            'total_entries': len(false_friends),
            'categories': categories
        },
        'false_friends': [to_swift_dict(ff) for ff in false_friends]
    }

    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(output, f, ensure_ascii=False, indent=2)

    print(f"Saved {len(false_friends)} entries to {output_path}")
    print(f"Statistics: {dict(stats['by_severity'])}")
    print(f"  By category: {dict(stats['by_category'])}")
    print(f"  By source: {dict(stats['by_source'])}")
    print(f"  Needs review: {stats['needs_review']}")


# =============================================================================
# Main
# =============================================================================

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Expand false friends database')
    parser.add_argument('--jckv', type=str, help='Path to JCKV Excel file')
    parser.add_argument('--curated', type=str, default='false_friends_v2.json', 
                        help='Path to curated false friends JSON')
    parser.add_argument('--auto-detect', action='store_true',
                        help='Auto-detect from JMDict/CEDICT')
    parser.add_argument('--jmdict', type=str, help='Path to JMDict data')
    parser.add_argument('--cedict', type=str, help='Path to CEDICT data')
    parser.add_argument('--output', type=str, default='output/false_friends_expanded.json',
                        help='Output path')
    
    args = parser.parse_args()
    
    # Load curated
    curated = []
    if os.path.exists(args.curated):
        curated = load_curated_false_friends(args.curated)
        print(f"Loaded {len(curated)} curated entries")
    
    # Load JCKV
    jckv = []
    if args.jckv and os.path.exists(args.jckv):
        jckv = convert_jckv_database(args.jckv)
    
    # Auto-detect
    auto = []
    if args.auto_detect and args.jmdict and args.cedict:
        auto = auto_detect_false_friends(args.jmdict, args.cedict)
    
    # Merge
    if curated or jckv or auto:
        merged = merge_false_friends(curated, jckv, auto)
        os.makedirs(os.path.dirname(args.output) or '.', exist_ok=True)
        save_false_friends(merged, args.output)
    else:
        print("No data to process. Provide --jckv, --curated, or --auto-detect")


if __name__ == '__main__':
    main()

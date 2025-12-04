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
    cn_meanings_simplified: List[str] = field(default_factory=list)
    cn_meanings_traditional: List[str] = field(default_factory=list)
    cn_example: str = ""
    cn_example_translation: str = ""
    
    explanation: str = ""
    mnemonic_tip: str = ""
    traditional_note: str = ""
    merged_from: List[str] = field(default_factory=list)
    
    # Metadata
    source: str = "auto"  # curated, jckv, auto
    confidence: float = 1.0
    needs_review: bool = False


# =============================================================================
# JCKV Database Converter
# =============================================================================

def convert_jckv_database(excel_path: str) -> List[FalseFriend]:
    """
    Convert Matsushita JCKV database to FalseFriend objects.
    
    The JCKV database classifies words into:
    - 同形同義 (S): Same form, same meaning - SKIP
    - 同形類義 (O1): Same + JP has extra meanings - INCLUDE
    - 同形類義 (O2): Same + CN has extra meanings - INCLUDE  
    - 同形類義 (O3): Both have extra unique meanings - INCLUDE
    - 同形異義 (D): Different meanings - INCLUDE (critical)
    - 非同形 (N): Not same form - SKIP
    """
    if not HAS_OPENPYXL:
        raise ImportError("openpyxl required: pip install openpyxl")
    
    wb = openpyxl.load_workbook(excel_path, read_only=True)
    ws = wb.active
    
    false_friends = []
    
    # Find header row and column indices
    headers = {}
    for idx, cell in enumerate(next(ws.iter_rows(min_row=1, max_row=1, values_only=True))):
        if cell:
            headers[cell] = idx
    
    # Expected columns (adjust based on actual JCKV structure):
    # 語, 読み, 中国語意味対応パタン, 日本語意味, 中国語意味, etc.
    
    print(f"Found columns: {list(headers.keys())}")
    
    # Process rows
    for row_idx, row in enumerate(ws.iter_rows(min_row=2, values_only=True), start=2):
        try:
            # Extract data (column indices depend on actual JCKV structure)
            word = row[headers.get('語', 0)] if '語' in headers else row[0]
            pattern = row[headers.get('中国語意味対応パタン', 2)] if '中国語意味対応パタン' in headers else row[2]
            
            if not word or not pattern:
                continue
            
            # Skip non-false-friends
            if pattern in ['S', '同形同義', 'N', '非同形']:
                continue
            
            # Determine severity and type
            if pattern in ['D', '同形異義']:
                severity = 'critical'
                ff_type = 4
            elif pattern in ['O1', 'O2', 'O3', '同形類義']:
                severity = 'important'
                ff_type = 3 if 'O3' in str(pattern) else (1 if 'O1' in str(pattern) else 2)
            else:
                severity = 'subtle'
                ff_type = 3
            
            # Extract meanings if available
            jp_meaning = row[headers.get('日本語意味', 3)] if '日本語意味' in headers else ""
            cn_meaning = row[headers.get('中国語意味', 4)] if '中国語意味' in headers else ""
            
            ff = FalseFriend(
                id=f"jckv_{row_idx:04d}",
                characters=str(word),
                type=ff_type,
                category="true_divergence",  # Default, can be refined
                severity=severity,
                affects="both",  # Default, can be refined
                jp_reading="",  # Need to add from JMDict
                jp_meanings=[str(jp_meaning)] if jp_meaning else [],
                cn_pinyin="",  # Need to add from CEDICT
                cn_meanings_simplified=[str(cn_meaning)] if cn_meaning else [],
                cn_meanings_traditional=[str(cn_meaning)] if cn_meaning else [],
                explanation=f"JCKV classification: {pattern}",
                source="jckv",
                confidence=0.9,
                needs_review=True
            )
            
            false_friends.append(ff)
            
        except Exception as e:
            print(f"Error processing row {row_idx}: {e}")
            continue
    
    print(f"Extracted {len(false_friends)} false friends from JCKV")
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
            cn_meanings_simplified=entry.get('cn_meanings_simplified', entry.get('cn_meanings', [])),
            cn_meanings_traditional=entry.get('cn_meanings_traditional', entry.get('cn_meanings', [])),
            cn_example=entry.get('cn_example', ''),
            cn_example_translation=entry.get('cn_example_translation', ''),
            explanation=entry.get('explanation', ''),
            mnemonic_tip=entry.get('mnemonic_tip', ''),
            traditional_note=entry.get('traditional_note', ''),
            merged_from=entry.get('merged_from', []),
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
    """Save false friends to JSON."""
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
    
    output = {
        'metadata': {
            'version': '3.0',
            'description': 'Expanded false friends database',
            'total_entries': len(false_friends),
            'statistics': {
                'by_severity': dict(stats['by_severity']),
                'by_source': dict(stats['by_source']),
                'by_category': dict(stats['by_category']),
                'needs_review': stats['needs_review']
            }
        },
        'false_friends': [asdict(ff) for ff in false_friends]
    }
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(output, f, ensure_ascii=False, indent=2)
    
    print(f"Saved {len(false_friends)} entries to {output_path}")
    print(f"Statistics: {dict(stats['by_severity'])}")
    print(f"Needs review: {stats['needs_review']}")


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

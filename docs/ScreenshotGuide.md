# App Store Screenshot Capture Guide

## Overview

This guide provides step-by-step instructions for capturing all required App Store screenshots for Yomikae.

---

## Required Screenshot Sizes

### iPhone Screenshots (Required)

| Device | Size (pixels) | Aspect Ratio |
|--------|---------------|--------------|
| iPhone 6.7" (15 Pro Max) | 1290 x 2796 | 19.5:9 |
| iPhone 6.5" (11 Pro Max) | 1242 x 2688 | 19.5:9 |

### iPad Screenshots (Optional but Recommended)

| Device | Size (pixels) | Aspect Ratio |
|--------|---------------|--------------|
| iPad Pro 12.9" | 2048 x 2732 | 4:3 |

---

## Screenshot Set (5 Required)

### Screenshot 1: Hero/Search Screen
**Purpose**: Show main interface and search functionality
**Priority**: Highest (this appears first)

### Screenshot 2: Character Detail
**Purpose**: Show dual-reading feature
**Priority**: High

### Screenshot 3: False Friends List
**Purpose**: Highlight unique feature
**Priority**: High

### Screenshot 4: False Friend Detail
**Purpose**: Show detailed comparison
**Priority**: Medium

### Screenshot 5: Search Results
**Purpose**: Show search in action
**Priority**: Medium

---

## Capture Instructions

### Setup

1. **Choose Simulator**
   ```bash
   # List available simulators
   xcrun simctl list devices | grep "iPhone 15 Pro Max"

   # Boot the simulator
   open -a Simulator
   # Hardware > Device > iPhone 15 Pro Max
   ```

2. **Prepare App State**
   - Build and run on simulator
   - Clear any test data
   - Ensure database is populated
   - Set device to light mode (or dark if capturing dark mode)

3. **Set Screenshot Location**
   ```bash
   # Create directory
   mkdir -p AppStore_Screenshots/iPhone_6.7
   ```

---

## Screenshot 1: Hero/Search Screen

### Setup
1. Launch app
2. Navigate to SearchView (should be default)
3. Clear search bar (empty state)
4. Ensure onboarding is completed

### Capture State
- **Screen**: SearchView
- **Search bar**: Empty or showing placeholder "Search by character or meaning..."
- **Recent searches**: None or minimal
- **Status bar**: Show time as 9:41 AM, full battery, full signal

### Take Screenshot
1. In Simulator: `Cmd + S` (saves to Desktop by default)
2. Or use: `xcrun simctl io booted screenshot hero_search.png`

### Post-Processing
- Add text overlay: "Bridge Your Chinese Knowledge to Japanese Mastery"
- Position: Top third
- Font: SF Pro Display, Bold, 48pt
- Color: White with subtle shadow
- Background overlay: Deep blue (#1E3A5F) at 60% opacity

---

## Screenshot 2: Character Detail

### Setup
1. From SearchView, search for: **手** (hand)
2. Tap the character to open CharacterDetailView
3. Ensure full details are visible

### Capture State
- **Character**: 手 (large at top)
- **Japanese readings**:
  - Onyomi: シュ (shu)
  - Kunyomi: て (te)
- **Chinese reading**: shǒu
- **Meanings visible**: hand
- **JLPT tag**: N5
- **Stroke count**: 4
- **Scroll position**: Top of view

### Take Screenshot
`Cmd + S` or `xcrun simctl io booted screenshot character_detail.png`

### Post-Processing
- Add text overlay: "Complete Readings in Both Languages"
- Position: Bottom third
- Highlight the dual reading sections with subtle glow

---

## Screenshot 3: False Friends List

### Setup
1. Navigate to FalseFriendsView
2. Ensure list shows variety of severity levels
3. Scroll to show these characters:
   - 勉強 (Critical - red badge)
   - 娘 (High - orange badge)
   - 大家 (Moderate - yellow badge)
   - 手紙 (Low - blue badge)

### Capture State
- **View**: FalseFriendsListView
- **Visible items**: 3-4 false friends with different severity
- **Show**: Character, severity badge, brief meaning difference
- **No search filter active**

### Take Screenshot
`Cmd + S` or `xcrun simctl io booted screenshot false_friends_list.png`

### Post-Processing
- Add text overlay: "40+ False Friends to Avoid Mistakes"
- Position: Top or bottom third
- Optional: Add small warning icon ⚠️ near text

---

## Screenshot 4: False Friend Detail

### Setup
1. From False Friends list, tap: **勉強**
2. Open FalseFriendDetailView
3. Ensure full comparison is visible

### Capture State
- **Character**: 勉強
- **Severity badge**: Critical (prominent)
- **Chinese meaning**: "reluctantly; to force oneself; to do with difficulty"
- **Japanese meaning**: "to study; study; diligence; discount"
- **Examples**: At least one example visible
- **Scroll position**: Top, showing both meanings clearly

### Take Screenshot
`Cmd + S` or `xcrun simctl io booted screenshot false_friend_detail.png`

### Post-Processing
- Add text overlay: "Learn Real Meanings, Not Assumptions"
- Position: Bottom third
- Highlight the meaning difference with visual elements

---

## Screenshot 5: Search Results

### Setup
1. Navigate to SearchView
2. Type in search: **学** or **study**
3. Wait for results to appear
4. Show 3-4 results

### Capture State
- **Search bar**: Showing active search term
- **Results visible**:
  - 学 (study)
  - 学校 (school) [if available]
  - 大学 (university) [if available]
- **Each result**: Shows character, reading, meaning
- **Some results**: Show false friend badges if applicable

### Take Screenshot
`Cmd + S` or `xcrun simctl io booted screenshot search_results.png`

### Post-Processing
- Add text overlay: "Search by Character, Reading, or Meaning"
- Position: Top third
- Optional: Add small magnifying glass icon 🔍

---

## Batch Capture Script

Create a script to automate screenshot capture:

```bash
#!/bin/bash
# capture_screenshots.sh

SIMULATOR_ID="your-simulator-id"
OUTPUT_DIR="AppStore_Screenshots/iPhone_6.7"

mkdir -p "$OUTPUT_DIR"

# Function to take screenshot
capture() {
    local name=$1
    local delay=$2
    sleep $delay
    xcrun simctl io booted screenshot "$OUTPUT_DIR/$name.png"
    echo "✅ Captured: $name"
}

# Launch app
xcrun simctl launch booted com.yourdomain.Yomikae

# Capture screenshots with delays for navigation
capture "01_hero_search" 2
# (Manual: Navigate to character detail)
capture "02_character_detail" 5
# (Manual: Navigate to false friends)
capture "03_false_friends_list" 3
# (Manual: Tap false friend)
capture "04_false_friend_detail" 2
# (Manual: Navigate back, search)
capture "05_search_results" 3

echo "🎉 All screenshots captured!"
```

---

## Post-Processing Workflow

### Tools Needed
- **Screenshot editing**: Figma, Sketch, Photoshop, or Pixelmator Pro
- **Text overlay**: Use app's brand fonts
- **Device frames**: Use from Apple or mokup.me

### Steps

1. **Clean Screenshots**
   - Crop if needed
   - Ensure exact dimensions
   - Remove any test artifacts

2. **Add Text Overlays**
   - Create overlay layer (deep blue at 60% opacity)
   - Add text (white, SF Pro Display Bold, 48pt)
   - Add subtle drop shadow for readability

3. **Add Device Frames** (Optional)
   - Use official Apple device frames
   - Ensure frames don't make file too large
   - Consider frameless for cleaner look

4. **Optimize Files**
   - Format: PNG (required by App Store)
   - Color profile: sRGB
   - File size: < 500KB per screenshot
   - No compression artifacts

5. **Quality Check**
   - View at thumbnail size (150px wide)
   - Ensure text is readable
   - Check contrast and colors
   - Verify no UI glitches visible

---

## Alternative Sizes

### For iPhone 6.5" (1242 x 2688)

Use same screenshots, resize:
```bash
sips -z 2688 1242 input.png --out output.png
```

Or create at 2x scale and let Xcode handle it.

### For iPad (2048 x 2732)

Capture from iPad simulator:
1. Open iPad Pro 12.9" simulator
2. Build and run on iPad
3. Capture same screens
4. Use same post-processing

iPad screenshots can show more content (landscape optional).

---

## Design Templates

### Text Overlay Template (Figma/Sketch)

**Dimensions**: 1290 x 2796px

**Layers**:
1. Background overlay rectangle
   - Color: #1E3A5F
   - Opacity: 60%
   - Position: Top or bottom third (350-400px high)

2. Text layer
   - Font: SF Pro Display Bold
   - Size: 48pt
   - Color: #FFFFFF
   - Shadow: 0px 2px 4px rgba(0,0,0,0.3)
   - Padding: 40px from edges

3. Screenshot layer
   - Actual app screenshot
   - Below overlay

---

## Localization Screenshots

For each supported language, create separate screenshots:

### Simplified Chinese (简体中文)
- Change device language to Chinese
- Rebuild app with Chinese strings
- Capture same 5 screenshots
- Use Chinese overlay text

### Traditional Chinese (繁體中文)
- Same process as Simplified

### Japanese (日本語)
- Same process

**Storage**:
```
AppStore_Screenshots/
├── en_US/
│   └── iPhone_6.7/
├── zh_CN/
│   └── iPhone_6.7/
├── zh_TW/
│   └── iPhone_6.7/
└── ja_JP/
    └── iPhone_6.7/
```

---

## Review Checklist

Before submitting screenshots:

- [ ] All 5 screenshots captured for iPhone 6.7"
- [ ] Screenshots show real app functionality
- [ ] No placeholder or Lorem Ipsum text
- [ ] Status bar shows 9:41 AM
- [ ] No network error indicators
- [ ] Text overlays are readable
- [ ] Colors match app branding
- [ ] File format: PNG
- [ ] Correct dimensions (1290 x 2796)
- [ ] File size < 500KB each
- [ ] Screenshots numbered/ordered correctly
- [ ] Optional: iPad screenshots captured
- [ ] Optional: Localized versions for each language

---

## App Store Connect Upload

1. Log into App Store Connect
2. Navigate to your app
3. Select version
4. Scroll to "App Preview and Screenshots"
5. Select device size (6.7" Display)
6. Drag and drop screenshots in order
7. Add captions if desired (optional)
8. Repeat for other device sizes
9. Save

---

## Tips for Great Screenshots

### Do's ✅
- Show real, compelling content
- Use actual app data, not placeholders
- Highlight unique features (false friends!)
- Keep text overlays short and punchy
- Show the app in action
- Use consistent design language
- Test readability at small sizes

### Don'ts ❌
- Don't use fake data
- Don't show error states
- Don't include personal information
- Don't use copyrighted content
- Don't make false claims in overlays
- Don't use too much text
- Don't have cluttered screens

---

## Example Text Overlays

Feel free to customize these:

1. "Bridge Chinese to Japanese"
2. "Learn Kanji You Already Know"
3. "Dual Readings, One Glance"
4. "Avoid False Friends"
5. "40+ Common Mistakes Explained"
6. "Search Any Way You Want"
7. "Made for Chinese Speakers"
8. "Your Chinese is Your Superpower"

---

## Troubleshooting

### Screenshot too dark
- Increase device brightness in simulator
- Adjust post-processing exposure

### Text not readable
- Increase overlay opacity
- Use stronger drop shadow
- Choose higher contrast colors

### Wrong dimensions
- Verify simulator is correct model
- Use `sips` command to resize
- Re-capture if needed

### Status bar shows wrong info
- Use Xcode's "Prepare for Screenshot" feature
- Or manually edit status bar in post-processing

---

## Resources

- [Apple Screenshot Specifications](https://help.apple.com/app-store-connect/#/devd274dd925)
- [App Store Connect Guide](https://developer.apple.com/app-store/app-screenshots/)
- [Screenshot Best Practices](https://developer.apple.com/design/human-interface-guidelines/app-store-marketing)

---

**Last Updated**: 2025-12-02
**Version**: 1.0

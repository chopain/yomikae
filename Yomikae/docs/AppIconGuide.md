# Yomikae App Icon Guide

## Icon Concept

**Theme**: Bridge connecting Japanese and Chinese characters
**Tagline**: 読み替え (Yomikae) - "Reading Conversion"

---

## Design Options

### Option 1: Bridge Between Characters (Recommended)
- **Top**: 漢 (Chinese character)
- **Middle**: Golden bridge (橋)
- **Bottom**: 字 (Japanese character)
- **Symbolism**: Direct representation of bridging Chinese knowledge to Japanese learning

### Option 2: Single Character 橋
- Large, bold 橋 (bridge) character
- Minimalist and immediately recognizable
- Works well at small sizes

### Option 3: Geometric Bridge
- Abstract arch bridge shape
- Modern, clean design
- Universal symbol

---

## Color Palette

### Primary Colors
- **Background**: `#1E3A5F` (Deep Blue) - Trust, knowledge, depth
- **Foreground**: `#FFFFFF` (White) - Clarity, purity
- **Accent**: `#E07B39` (Warm Orange/Gold) - Connection, enlightenment

### Alternative Palettes
- **Traditional**: Red (#D32F2F) + Gold (#FFD700) + Deep Blue
- **Modern**: Navy (#0A1929) + Cyan (#00BCD4) + White
- **Elegant**: Indigo (#3F51B5) + Purple (#9C27B0) + Gold

---

## Technical Requirements

### iOS App Icon Sizes
All icons must be **PNG format, no transparency**:

| Size (pt) | Size (px @3x) | Device/Use |
|-----------|---------------|------------|
| 20pt      | 60x60         | Notifications (iPhone) |
| 29pt      | 87x87         | Settings (iPhone) |
| 40pt      | 120x120       | Spotlight (iPhone) |
| 60pt      | 180x180       | Home Screen (iPhone) |
| 76pt      | 228x228       | Home Screen (iPad) |
| 83.5pt    | 250.5x250.5   | Home Screen (iPad Pro) |
| 1024pt    | 1024x1024     | App Store |

### Asset Catalog Structure
```
Assets.xcassets/
└── AppIcon.appiconset/
    ├── Contents.json
    ├── icon-20@2x.png (40x40)
    ├── icon-20@3x.png (60x60)
    ├── icon-29@2x.png (58x58)
    ├── icon-29@3x.png (87x87)
    ├── icon-40@2x.png (80x80)
    ├── icon-40@3x.png (120x120)
    ├── icon-60@2x.png (120x120)
    ├── icon-60@3x.png (180x180)
    ├── icon-76.png (76x76)
    ├── icon-76@2x.png (152x152)
    ├── icon-83.5@2x.png (167x167)
    └── icon-1024.png (1024x1024)
```

---

## Design Guidelines

### Do's ✅
- **Keep it simple**: Icon should be recognizable at 60x60 pixels
- **Use high contrast**: Background vs. foreground
- **Center the design**: Leave ~10% margin on all sides
- **Test at all sizes**: View at 60px, 80px, 120px, 180px
- **Avoid gradients**: Or use them very subtly
- **Make it unique**: Stand out in the App Store

### Don'ts ❌
- **No transparency**: iOS will add black background
- **No text smaller than 40pt**: (at 1024x1024 size)
- **No fine details**: They'll be lost at small sizes
- **No photos**: Abstract/illustrated works better
- **No rounded corners**: iOS adds them automatically

---

## Creation Workflow

### Method 1: Using Figma/Sketch (Recommended)
1. **Create 1024x1024 artboard** with deep blue background
2. **Add your design** centered with ~100px margin
3. **Export as PNG** at 1x, 2x, 3x for all required sizes
4. **Use Icon Generator** tool to create all sizes automatically

### Method 2: Using SF Symbols (Quick Prototype)
1. Use the `AppIconPreview.swift` view in Xcode
2. Select your preferred design
3. Adjust colors
4. Take screenshots for testing

### Method 3: Using Online Tools
1. **AppIconGenerator.net** - Upload 1024x1024, get all sizes
2. **MakeAppIcon.com** - Similar functionality
3. **Appicon.co** - Alternative generator

---

## Recommended Tools

### Design Software
- **Figma** (Free): Best for web-based design
- **Sketch** (Mac): Professional icon design
- **Affinity Designer**: One-time purchase alternative
- **Adobe Illustrator**: Industry standard

### Icon Generators
- **AppIconGenerator.net** - Free, fast
- **IconKitchen** - Android + iOS
- **MakeAppIcon** - Batch processing

### Testing Tools
- **Icon Preview in Xcode**: View in actual app context
- **AppIconPreview.swift**: Live preview of designs

---

## Step-by-Step: Creating Your Icon

### Step 1: Design the Master (1024x1024)
```
1. Open Figma/Sketch
2. Create 1024x1024 artboard
3. Add background rectangle (#1E3A5F)
4. Add your character(s) centered
   - 漢 at top: 300px font size
   - Bridge: 80px height
   - 字 at bottom: 300px font size
5. Add accent color to bridge (#E07B39)
6. Leave 100px margin on all sides
7. Export as PNG
```

### Step 2: Generate All Sizes
```bash
# Use AppIconGenerator.net or run this command:
# (requires ImageMagick: brew install imagemagick)

convert icon-1024.png -resize 180x180 icon-60@3x.png
convert icon-1024.png -resize 120x120 icon-60@2x.png
convert icon-1024.png -resize 120x120 icon-40@3x.png
convert icon-1024.png -resize 87x87 icon-29@3x.png
# ... etc for all sizes
```

### Step 3: Add to Xcode
1. Open `Assets.xcassets/AppIcon.appiconset`
2. Drag and drop each icon to its slot
3. Or use the AppIconGenerator tool to generate Contents.json

---

## Quick Start: Placeholder Icon

Use the included `AppIconPreview.swift` to:
1. Preview different designs
2. Choose your favorite
3. Screenshot at different sizes
4. Use temporarily while designing final icon

### Temporary SF Symbol Icon
```swift
// In your AppIconPreview, use "sf Symbol" design
// This uses system symbols to create a quick placeholder
```

---

## Brand Consistency

Your app icon should match:
- **App name**: 読み替え (Yomikae)
- **Primary color**: Deep Blue (#1E3A5F)
- **Accent color**: Warm Orange (#E07B39)
- **Theme**: Bridge, connection, learning
- **Tone**: Professional, educational, friendly

---

## Testing Checklist

Before finalizing:
- [ ] Test on iPhone home screen
- [ ] Test on iPad home screen
- [ ] Test in Settings app
- [ ] Test in App Store listing
- [ ] Test in Spotlight search
- [ ] Test in notifications
- [ ] View at arm's length
- [ ] View in grayscale
- [ ] Compare with competitor apps

---

## Resources

### Inspiration
- **Apple Design Resources**: developer.apple.com/design/resources
- **SF Symbols**: developer.apple.com/sf-symbols
- **Material Design Icons**: material.io/resources/icons

### Fonts for Characters
- **Noto Sans CJK**: Google's pan-CJK font
- **Source Han Sans**: Adobe's CJK font
- **System Fonts**: SF Pro, PingFang SC/TC

### Color Tools
- **Coolors.co**: Generate color palettes
- **Adobe Color**: Color wheel and schemes
- **Material Design Color Tool**: palette.material.io

---

## Future Iterations

Consider seasonal or special variants:
- **Dark mode icon**: Inverted colors
- **Holiday themes**: Spring/Summer/Fall/Winter variants
- **Achievement badges**: Special icons for milestones
- **Widget icons**: Smaller, simpler versions

---

## Need Help?

1. Use `AppIconPreview.swift` in Xcode to experiment
2. Take screenshots of designs you like
3. Use online generators for production icons
4. Test thoroughly before submission

#!/bin/bash

# Generate Placeholder App Icons for Yomikae
# Requires ImageMagick: brew install imagemagick

set -e

# Colors
BG_COLOR="#1E3A5F"  # Deep blue
FG_COLOR="#FFFFFF"  # White
ACCENT_COLOR="#E07B39"  # Warm orange

# Output directory
OUTPUT_DIR="Yomikae/Assets.xcassets/AppIcon.appiconset"

echo "🎨 Generating placeholder app icons for Yomikae..."

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "❌ Error: ImageMagick not found. Install with: brew install imagemagick"
    exit 1
fi

# Function to create icon at specific size
create_icon() {
    local size=$1
    local filename=$2

    echo "  Creating ${filename} (${size}x${size})..."

    # Create base with background
    convert -size ${size}x${size} xc:"${BG_COLOR}" \
        -fill "${FG_COLOR}" \
        -font "PingFang-SC-Regular" \
        -pointsize $((size / 3)) \
        -gravity North \
        -annotate +0+$((size / 8)) "漢" \
        -pointsize $((size / 3)) \
        -gravity South \
        -annotate +0+$((size / 8)) "字" \
        -fill "${ACCENT_COLOR}" \
        -draw "roundrectangle $((size / 4)),$((size / 2 - size / 20)) $((size * 3 / 4)),$((size / 2 + size / 20)) 5,5" \
        "${OUTPUT_DIR}/${filename}"
}

# Generate all required sizes for iOS
echo "📱 Generating iOS icon sizes..."

# iPhone Notification (iOS 7-15)
create_icon 40 "icon-20@2x.png"
create_icon 60 "icon-20@3x.png"

# iPhone Settings (iOS 7-15)
create_icon 58 "icon-29@2x.png"
create_icon 87 "icon-29@3x.png"

# iPhone Spotlight (iOS 7-15)
create_icon 80 "icon-40@2x.png"
create_icon 120 "icon-40@3x.png"

# iPhone App (iOS 7-15)
create_icon 120 "icon-60@2x.png"
create_icon 180 "icon-60@3x.png"

# iPad Notifications (iOS 7-15)
create_icon 20 "icon-20.png"
create_icon 40 "icon-20@2x-ipad.png"

# iPad Settings (iOS 7-15)
create_icon 29 "icon-29.png"
create_icon 58 "icon-29@2x-ipad.png"

# iPad Spotlight (iOS 7-15)
create_icon 40 "icon-40.png"
create_icon 80 "icon-40@2x-ipad.png"

# iPad App (iOS 7-15)
create_icon 76 "icon-76.png"
create_icon 152 "icon-76@2x.png"

# iPad Pro App (iOS 9-15)
create_icon 167 "icon-83.5@2x.png"

# App Store
echo "🏪 Generating App Store icon (1024x1024)..."
create_icon 1024 "icon-1024.png"

echo "✅ Icon generation complete!"
echo ""
echo "📋 Next steps:"
echo "  1. Open Xcode and navigate to Assets.xcassets"
echo "  2. Select AppIcon"
echo "  3. The icons should appear automatically"
echo "  4. For production, create a proper design using Figma/Sketch"
echo "  5. See docs/AppIconGuide.md for detailed instructions"

# Yomikae Launch Screen Guide

## Overview

Yomikae includes two launch screen implementations:

1. **SwiftUI-based** (`LaunchScreenView.swift`) - Modern, animated
2. **Storyboard-based** (`LaunchScreen.storyboard`) - Traditional, compatible

Both have identical visual design with the app name "読み替え", subtitle "Yomikae", tagline, and bridge icon on a deep blue gradient background.

---

## Current Configuration

**Currently Active**: SwiftUI Launch Screen (with animations)

The project is configured with `INFOPLIST_KEY_UILaunchScreen_Generation = YES`, which enables SwiftUI-based launch screens.

---

## Option 1: SwiftUI Launch Screen (Current)

### Features
- Fade-in animations on app launch
- Gradient background
- Modern SwiftUI code
- iOS 14+ compatible

### Files
- `Yomikae/Views/Launch/LaunchScreenView.swift`
  - `LaunchScreenView` - Animated version
  - `StaticLaunchScreenView` - Non-animated variant

### How to Use

**No configuration needed** - it's already active. The system automatically shows `LaunchScreenView` when the app launches.

To use the static variant instead:
1. Open `YomikaeApp.swift`
2. Uncomment/add this code if you want a custom launch screen that persists:
```swift
@main
struct YomikaeApp: App {
    @State private var isLoading = true

    var body: some Scene {
        WindowGroup {
            if isLoading {
                LaunchScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isLoading = false
                        }
                    }
            } else {
                ContentView()
            }
        }
    }
}
```

---

## Option 2: Storyboard Launch Screen

### Features
- No animations (instant display)
- More traditional approach
- Works on all iOS versions
- Faster initial load

### File
- `Yomikae/LaunchScreen.storyboard`

### How to Switch

1. **Open Xcode**
2. **Select the project** in the navigator (Yomikae)
3. **Select the Yomikae target**
4. **Go to Info tab**
5. **Find or add key**: `Launch Screen`
6. **Set value to**: `LaunchScreen` (the storyboard name without .storyboard extension)
7. **Or** edit `project.pbxproj` and change:
   ```
   INFOPLIST_KEY_UILaunchScreen_Generation = YES;
   ```
   to:
   ```
   INFOPLIST_KEY_UILaunchScreen_Generation = NO;
   INFOPLIST_KEY_UILaunchStoryboardName = LaunchScreen;
   ```

---

## Design Details

Both implementations use the same visual design:

### Colors
- **Background**: Deep blue gradient (`#1E3A5F` to `#2A4A7F`)
- **App Name**: White with subtle gradient
- **Subtitle**: White at 90% opacity
- **Tagline**: White at 70% opacity
- **Bridge Icon**: Warm orange/gold (`#E07B39`)

### Typography
- **App Name "読み替え"**: 56pt, bold, rounded font
- **Subtitle "Yomikae"**: 20pt, medium weight, letter spacing
- **Tagline**: 14pt, regular weight

### Layout
- All text centered horizontally
- App name positioned slightly above center
- Subtitle 15pt below app name
- Tagline 12pt below subtitle
- Bridge icon near bottom with adequate spacing

---

## Testing the Launch Screen

### In Simulator
1. Build and run the app
2. Force quit the app (Cmd + Shift + H + H)
3. Tap the app icon to see the launch screen

### On Device
1. Install the app on a physical device
2. Delete the app
3. Reinstall to see the launch screen on first launch

### Quick Preview
- SwiftUI: Use Xcode previews in `LaunchScreenView.swift`
- Storyboard: Open `LaunchScreen.storyboard` in Interface Builder

---

## Troubleshooting

### Launch screen not updating?
**Delete the app and reinstall**. iOS caches launch screens aggressively.

### Want to remove animations?
Use `StaticLaunchScreenView` instead of `LaunchScreenView`.

### Storyboard not appearing?
1. Check that it's added to the target (Target Membership)
2. Verify the storyboard name in Info.plist
3. Clean build folder (Cmd + Shift + K) and rebuild

---

## Which Should You Use?

### Use SwiftUI Launch Screen if:
- You want smooth animations on app launch
- You're targeting iOS 14+ only
- You prefer modern SwiftUI code
- You want a dynamic launch experience

### Use Storyboard Launch Screen if:
- You need maximum compatibility
- You prefer faster initial load (no animation overhead)
- You want the traditional iOS approach
- You're familiar with Interface Builder

---

## Future Enhancements

Potential improvements for the launch screen:

1. **Localization**: Show app name in different languages
2. **Dynamic colors**: Support system light/dark mode
3. **Seasonal themes**: Different backgrounds for holidays
4. **Progress indicator**: Show loading state for slow connections
5. **App version**: Display version number during development

---

## Technical Notes

### SwiftUI Approach
- Uses `@State` for animation control
- Custom `Arch` shape for bridge icon
- Gradient backgrounds with `LinearGradient`
- Animation with `.onAppear` and `withAnimation`

### Storyboard Approach
- Uses Auto Layout constraints
- Static views (no animations possible)
- Simple shapes for bridge representation
- XML-based configuration

### Performance
Both approaches are lightweight and launch quickly. The SwiftUI version adds ~100ms for animations but provides a more polished experience.

---

## Resources

- [Apple HIG: Launch Screens](https://developer.apple.com/design/human-interface-guidelines/launch-screen)
- [SwiftUI Launch Screens (WWDC)](https://developer.apple.com/videos/play/wwdc2021/10030/)
- [Launch Screen Best Practices](https://developer.apple.com/design/human-interface-guidelines/launch-screen#Best-practices)

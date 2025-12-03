import SwiftUI

/// Developer tool for previewing and generating app icon designs
struct AppIconPreview: View {
    @State private var selectedDesign: IconDesign = .bridge
    @State private var backgroundColor: Color = Color(hex: "1E3A5F")
    @State private var foregroundColor: Color = .white
    @State private var accentColor: Color = Color(hex: "E07B39")

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Large preview
                iconPreview
                    .frame(width: 300, height: 300)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .shadow(radius: 10)

                // Design selector
                designPicker

                // Color controls
                colorControls

                // Size previews
                sizePreviewGrid

                Spacer()
            }
            .padding()
            .navigationTitle("App Icon Preview")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Export Tips") {
                        // Show export guidance
                    }
                }
            }
        }
    }

    // MARK: - Icon Preview

    @ViewBuilder
    private var iconPreview: some View {
        ZStack {
            backgroundColor

            switch selectedDesign {
            case .bridge:
                bridgeDesign
            case .character:
                characterDesign
            case .simplified:
                simplifiedDesign
            case .sfSymbol:
                sfSymbolDesign
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 60, style: .continuous))
    }

    // Design 1: Bridge connecting 漢 and 字
    private var bridgeDesign: some View {
        VStack(spacing: 0) {
            // Top character
            Text("漢")
                .font(.system(size: 90, weight: .bold))
                .foregroundColor(foregroundColor)

            // Bridge
            ZStack {
                // Bridge deck
                RoundedRectangle(cornerRadius: 8)
                    .fill(accentColor)
                    .frame(width: 160, height: 20)

                // Bridge supports
                HStack(spacing: 120) {
                    ForEach(0..<2) { _ in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(accentColor)
                            .frame(width: 10, height: 60)
                    }
                }
            }
            .offset(y: -10)

            // Bottom character
            Text("字")
                .font(.system(size: 90, weight: .bold))
                .foregroundColor(foregroundColor)
                .offset(y: -20)
        }
    }

    // Design 2: Single 橋 character
    private var characterDesign: some View {
        ZStack {
            // Glow effect
            Text("橋")
                .font(.system(size: 200, weight: .heavy))
                .foregroundColor(accentColor)
                .blur(radius: 20)
                .opacity(0.5)

            // Main character
            Text("橋")
                .font(.system(size: 180, weight: .heavy))
                .foregroundColor(foregroundColor)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }

    // Design 3: Simplified geometric bridge
    private var simplifiedDesign: some View {
        VStack(spacing: 40) {
            // Top dot
            Circle()
                .fill(foregroundColor)
                .frame(width: 30, height: 30)

            // Arch bridge
            ZStack {
                // Bridge arch
                Arch()
                    .stroke(foregroundColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 180, height: 100)

                // Bridge deck
                RoundedRectangle(cornerRadius: 10)
                    .fill(accentColor)
                    .frame(width: 200, height: 15)
                    .offset(y: 50)
            }

            // Bottom dot
            Circle()
                .fill(foregroundColor)
                .frame(width: 30, height: 30)
        }
    }

    // Design 4: SF Symbol based
    private var sfSymbolDesign: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [backgroundColor, backgroundColor.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 16) {
                // Bridge symbol
                Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(accentColor)

                // Characters
                HStack(spacing: 8) {
                    Text("読")
                    Text("替")
                }
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(foregroundColor)
            }
        }
    }

    // MARK: - Controls

    private var designPicker: some View {
        Picker("Design", selection: $selectedDesign) {
            ForEach(IconDesign.allCases) { design in
                Text(design.rawValue).tag(design)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    private var colorControls: some View {
        VStack(spacing: 12) {
            ColorPicker("Background", selection: $backgroundColor)
            ColorPicker("Foreground", selection: $foregroundColor)
            ColorPicker("Accent", selection: $accentColor)
        }
        .padding(.horizontal)
    }

    // MARK: - Size Previews

    private var sizePreviewGrid: some View {
        VStack(spacing: 16) {
            Text("iOS Icon Sizes")
                .font(.headline)

            HStack(spacing: 20) {
                iconSizePreview(size: 60, label: "60pt")
                iconSizePreview(size: 80, label: "80pt")
                iconSizePreview(size: 100, label: "100pt")
            }
        }
    }

    private func iconSizePreview(size: CGFloat, label: String) -> some View {
        VStack(spacing: 8) {
            iconPreview
                .frame(width: size, height: size)

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Supporting Types

enum IconDesign: String, CaseIterable, Identifiable {
    case bridge = "Bridge"
    case character = "Character"
    case simplified = "Geometric"
    case sfSymbol = "SF Symbol"

    var id: String { rawValue }
}

// MARK: - Custom Shapes

struct Arch: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint(x: 0, y: height))

        // Create an arch using quadratic curve
        path.addQuadCurve(
            to: CGPoint(x: width, y: height),
            control: CGPoint(x: width / 2, y: 0)
        )

        return path
    }
}

// MARK: - Preview

#Preview {
    AppIconPreview()
}

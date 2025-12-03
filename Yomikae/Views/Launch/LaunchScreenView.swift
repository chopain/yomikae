import SwiftUI

/// Modern SwiftUI-based launch screen for iOS 14+
struct LaunchScreenView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "1E3A5F"),  // Deep blue
                    Color(hex: "2A4A7F")   // Slightly lighter blue
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Content
            VStack(spacing: 24) {
                Spacer()

                // Main app name (Japanese)
                Text("読み替え")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color(hex: "E0E0E0")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .scaleEffect(isAnimating ? 1.0 : 0.9)
                    .opacity(isAnimating ? 1.0 : 0.0)

                // Subtitle (Romanization)
                Text("Yomikae")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .tracking(2)
                    .opacity(isAnimating ? 1.0 : 0.0)

                // Tagline
                Text("Learn Kanji Using Chinese")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .opacity(isAnimating ? 1.0 : 0.0)

                Spacer()

                // Bridge icon
                bridgeIcon
                    .opacity(isAnimating ? 1.0 : 0.0)

                Spacer()
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }

    // MARK: - Bridge Icon

    private var bridgeIcon: some View {
        ZStack {
            // Bridge arch
            Arch()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(hex: "E07B39"),  // Warm orange
                            Color(hex: "F0A050")   // Lighter orange
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 80, height: 40)

            // Connection dots
            HStack(spacing: 60) {
                ForEach(0..<2) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 8, height: 8)
                }
            }
            .offset(y: 20)
        }
        .scaleEffect(isAnimating ? 1.0 : 0.5)
    }
}

// MARK: - Static Launch Screen (for Storyboard alternative)

/// Static version without animations for use in storyboard or static contexts
struct StaticLaunchScreenView: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "1E3A5F"),
                    Color(hex: "2A4A7F")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Content
            VStack(spacing: 24) {
                Spacer()

                // Main app name
                Text("読み替え")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color(hex: "E0E0E0")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

                // Subtitle
                Text("Yomikae")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .tracking(2)

                // Tagline
                Text("Learn Kanji Using Chinese")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))

                Spacer()

                // Bridge icon
                ZStack {
                    Arch()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: "E07B39"),
                                    Color(hex: "F0A050")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 80, height: 40)

                    HStack(spacing: 60) {
                        ForEach(0..<2) { _ in
                            Circle()
                                .fill(Color.white.opacity(0.8))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .offset(y: 20)
                }

                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Previews

#Preview("Animated Launch") {
    LaunchScreenView()
}

#Preview("Static Launch") {
    StaticLaunchScreenView()
}

#Preview("Dark Mode") {
    LaunchScreenView()
        .preferredColorScheme(.dark)
}

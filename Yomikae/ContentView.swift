//
//  ContentView.swift
//  Yomikae
//
//  Created on 2025-11-28.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var settings = UserSettings.shared
    @State private var showOnboarding = false

    var body: some View {
        TabView {
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            FalseFriendsListView()
                .tabItem {
                    Label("False Friends", systemImage: "exclamationmark.triangle")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView()
                .interactiveDismissDisabled()
        }
        .onAppear {
            // Check if user has completed onboarding
            if !settings.hasCompletedOnboarding {
                showOnboarding = true
            }
        }
    }
}

#Preview {
    ContentView()
}

#Preview("Settings") {
    SettingsView()
}

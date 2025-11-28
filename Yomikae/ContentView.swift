//
//  ContentView.swift
//  Yomikae
//
//  Created on 2025-11-28.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            FalseFriendsView()
                .tabItem {
                    Label("False Friends", systemImage: "exclamationmark.triangle")
                }

            DatabaseTestView()
                .tabItem {
                    Label("DB Test", systemImage: "cylinder")
                }
        }
    }
}

#Preview {
    ContentView()
}

//
//  SearchView.swift
//  Yomikae
//
//  Created on 2025-11-28.
//

import SwiftUI

struct SearchView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Search for characters")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Search")
        }
    }
}

#Preview {
    SearchView()
}

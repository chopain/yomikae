//
//  FalseFriendsView.swift
//  Yomikae
//
//  Created on 2025-11-28.
//

import SwiftUI

struct FalseFriendsView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("False Friends")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("False Friends")
        }
    }
}

#Preview {
    FalseFriendsView()
}

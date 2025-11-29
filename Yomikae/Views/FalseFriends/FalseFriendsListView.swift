import SwiftUI

struct FalseFriendsListView: View {
    @StateObject private var viewModel = FalseFriendsViewModel()
    @ObservedObject private var settings = UserSettings.shared
    @State private var showOnlyRelevant = false
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                // Stats Summary Section
                statsSection

                // Filter Controls Section
                filterControlsSection

                // False Friends List grouped by severity
                falseFriendsListSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("False Friends")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: FalseFriend.self) { falseFriend in
                FalseFriendDetailView(falseFriend: falseFriend)
            }
            .refreshable {
                await viewModel.refresh()
            }
            .overlay {
                if viewModel.isLoading && viewModel.falseFriends.isEmpty {
                    ProgressView()
                } else if displayedFalseFriends.isEmpty {
                    emptyStateView
                }
            }
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        Section {
            VStack(spacing: 16) {
                // Total count
                HStack {
                    Text("Total False Friends")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(viewModel.totalCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                }

                Divider()

                // Severity breakdown
                HStack(spacing: 12) {
                    SeverityStatBox(
                        severity: .critical,
                        count: viewModel.criticalCount
                    )

                    SeverityStatBox(
                        severity: .important,
                        count: viewModel.importantCount
                    )

                    SeverityStatBox(
                        severity: .subtle,
                        count: viewModel.subtleCount
                    )
                }

                Divider()

                // Relevance info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Relevant to You")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack(spacing: 4) {
                            Text("Reading:")
                            Text(settings.chineseSystem.rawValue.capitalized)
                                .fontWeight(.semibold)
                                .foregroundColor(.accentColor)
                        }
                        .font(.caption)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(viewModel.relevantCount)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)

                        Text("of \(viewModel.totalCount)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("Statistics")
        }
    }

    // MARK: - Filter Controls Section

    private var filterControlsSection: some View {
        Section {
            // Severity filter
            Picker("Severity Filter", selection: $viewModel.selectedSeverity) {
                Text("All Severities").tag(nil as Severity?)
                Divider()
                ForEach(Severity.allCases, id: \.self) { severity in
                    Label(severity.displayName, systemImage: severity.icon)
                        .tag(severity as Severity?)
                }
            }
            .pickerStyle(.menu)

            // Relevance toggle
            Toggle(isOn: $showOnlyRelevant) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Show Only Relevant to Me")
                        .font(.body)

                    Text("Filters based on your Chinese system (\(settings.chineseSystem.rawValue))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .tint(.accentColor)

            // Active filters summary
            if viewModel.selectedSeverity != nil || showOnlyRelevant {
                HStack {
                    Text("Showing:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(displayedFalseFriends.count) items")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)

                    Spacer()

                    Button("Clear Filters") {
                        viewModel.selectedSeverity = nil
                        showOnlyRelevant = false
                    }
                    .font(.caption)
                }
            }
        } header: {
            Text("Filters")
        }
    }

    // MARK: - False Friends List Section

    private var falseFriendsListSection: some View {
        ForEach(groupedFalseFriends, id: \.severity) { group in
            Section {
                ForEach(group.items) { falseFriend in
                    Button(action: {
                        navigationPath.append(falseFriend)
                    }) {
                        FalseFriendRow(falseFriend: falseFriend)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
            } header: {
                sectionHeader(for: group)
            }
        }
    }

    @ViewBuilder
    private func sectionHeader(for group: FalseFriendGroup) -> some View {
        HStack {
            Image(systemName: group.severity.icon)
                .foregroundColor(group.severity.color)

            Text(group.severity.displayName)
                .fontWeight(.semibold)

            Text("(\(group.items.count))")
                .foregroundColor(.secondary)

            // Show indicator if section has simplified-only items
            if group.items.contains(where: { $0.affectedSystem == .simplifiedOnly }) {
                Spacer()

                HStack(spacing: 4) {
                    Text("简")
                        .font(.caption2)
                        .fontWeight(.bold)
                    Text("Some items")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }

            // Show indicator if section has traditional-only items
            if group.items.contains(where: { $0.affectedSystem == .traditionalOnly }) {
                Spacer()

                HStack(spacing: 4) {
                    Text("繁")
                        .font(.caption2)
                        .fontWeight(.bold)
                    Text("Some items")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        ContentUnavailableView(
            "No False Friends Found",
            systemImage: "checkmark.circle.fill",
            description: Text(emptyStateDescription)
        )
        .foregroundColor(.green)
    }

    private var emptyStateDescription: String {
        if showOnlyRelevant {
            return "No false friends affect your Chinese system (\(settings.chineseSystem.rawValue)).\nTry adjusting your filters."
        } else if viewModel.selectedSeverity != nil {
            return "No false friends match your selected severity.\nTry selecting a different filter."
        } else {
            return "No false friends available."
        }
    }

    // MARK: - Computed Properties

    private var displayedFalseFriends: [FalseFriend] {
        var results = viewModel.filteredResults

        if showOnlyRelevant {
            results = results.filter { viewModel.isRelevantToUser($0) }
        }

        return results
    }

    private var groupedFalseFriends: [FalseFriendGroup] {
        let severities = Severity.allCases

        return severities.compactMap { severity in
            let items = displayedFalseFriends.filter { $0.severity == severity }
            guard !items.isEmpty else { return nil }
            return FalseFriendGroup(severity: severity, items: items)
        }
    }
}

// MARK: - Supporting Types

struct FalseFriendGroup {
    let severity: Severity
    let items: [FalseFriend]
}

// MARK: - Severity Stat Box

private struct SeverityStatBox: View {
    let severity: Severity
    let count: Int

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: severity.icon)
                .font(.title3)
                .foregroundColor(severity.color)

            Text("\(count)")
                .font(.headline)
                .fontWeight(.bold)

            Text(severity.displayName)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(severity.color.opacity(0.1))
        )
    }
}

// MARK: - Previews

#Preview {
    FalseFriendsListView()
}

#Preview("With Filters") {
    let view = FalseFriendsListView()
    return view
        .onAppear {
            // Simulate having data
        }
}

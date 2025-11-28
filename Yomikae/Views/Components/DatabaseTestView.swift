//
//  DatabaseTestView.swift
//  Yomikae
//
//  Created on 2025-11-28.
//

import SwiftUI
import GRDB

struct DatabaseTestView: View {
    @State private var testResult: String = "Tap to test database"
    @State private var isSuccess: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("GRDB Database Test")
                .font(.title2)
                .fontWeight(.bold)

            Text(testResult)
                .font(.body)
                .foregroundStyle(isSuccess ? .green : .primary)
                .multilineTextAlignment(.center)
                .padding()

            Button("Run Test") {
                runDatabaseTest()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func runDatabaseTest() {
        do {
            // Create an in-memory database
            let dbService = try DatabaseService(inMemory: true)
            guard let dbQueue = dbService.getQueue() else {
                testResult = "Failed to create database"
                isSuccess = false
                return
            }

            // Create the table
            try dbQueue.write { db in
                try TestRecord.createTable(in: db)
            }

            // Insert a test record
            var testRecord = TestRecord(message: "Hello from GRDB!")
            try dbQueue.write { db in
                try testRecord.insert(db)
            }

            // Query the record back
            let records = try dbQueue.read { db in
                try TestRecord.fetchAll(db)
            }

            if let first = records.first {
                testResult = """
                ✅ GRDB is working!

                Inserted and retrieved:
                ID: \(first.id ?? 0)
                Message: \(first.message)
                Time: \(formatDate(first.createdAt))
                """
                isSuccess = true
            } else {
                testResult = "No records found"
                isSuccess = false
            }
        } catch {
            testResult = "❌ Error: \(error.localizedDescription)"
            isSuccess = false
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    DatabaseTestView()
}

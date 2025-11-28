//
//  DatabaseService.swift
//  Yomikae
//
//  Created on 2025-11-28.
//

import Foundation
import GRDB

class DatabaseService {
    private var dbQueue: DatabaseQueue?

    init(inMemory: Bool = false) throws {
        if inMemory {
            // Create an in-memory database for testing
            dbQueue = try DatabaseQueue()
        } else {
            // Create a persistent database
            let fileManager = FileManager.default
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let dbPath = documentsPath.appendingPathComponent("yomikae.sqlite").path
            dbQueue = try DatabaseQueue(path: dbPath)
        }
    }

    func getQueue() -> DatabaseQueue? {
        return dbQueue
    }
}

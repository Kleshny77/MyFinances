//
//  SwiftDataBackupStorage.swift
//  MyFinances
//
//  Created by Артём on 19.07.2025.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataBackupStorage: BackupStorage {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init() throws {
        let schema = Schema([
            LocalTransaction.self,
            BackupOperation.self,
            LocalAccount.self,
            LocalCategory.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema)
        self.modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        self.modelContext = ModelContext(modelContainer)
    }
    
    func getAllBackupOperations() async throws -> [BackupOperation] {
        let descriptor = FetchDescriptor<BackupOperation>()
        return try modelContext.fetch(descriptor)
    }
    
    func getBackupOperations(accountId: Int) async throws -> [BackupOperation] {
        let descriptor = FetchDescriptor<BackupOperation>(
            predicate: #Predicate<BackupOperation> { operation in
                operation.accountId == accountId
            }
        )
        return try modelContext.fetch(descriptor)
    }
    
    func addBackupOperation(_ operation: BackupOperation) async throws {
        let operationId = operation.id
        let existingDescriptor = FetchDescriptor<BackupOperation>(
            predicate: #Predicate<BackupOperation> { existingOperation in
                existingOperation.id == operationId
            }
        )
        let existingOperations = try modelContext.fetch(existingDescriptor)
        
        for existingOperation in existingOperations {
            modelContext.delete(existingOperation)
        }
        
        modelContext.insert(operation)
        try modelContext.save()
    }
    
    func removeBackupOperation(id: Int) async throws {
        let operationId = id
        let descriptor = FetchDescriptor<BackupOperation>(
            predicate: #Predicate<BackupOperation> { operation in
                operation.id == operationId
            }
        )
        let operations = try modelContext.fetch(descriptor)
        
        for operation in operations {
            modelContext.delete(operation)
        }
        try modelContext.save()
    }
    
    func clearAll() async throws {
        let descriptor = FetchDescriptor<BackupOperation>()
        let operations = try modelContext.fetch(descriptor)
        
        for operation in operations {
            modelContext.delete(operation)
        }
        try modelContext.save()
    }
} 
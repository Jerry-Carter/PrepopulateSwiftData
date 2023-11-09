//
//  DatabaseBuilder.swift
//

import ArgumentParser
import Foundation           // For FileManager
import Logging
import PostgresNIO
import SwiftData


@main struct DatabaseBuilder: AsyncParsableCommand {
    static var _commandName = "ClientDatabaseBuilder"
    
    @Argument(help: "Path to generated SwiftData database")
    var databasePath:String
    
    mutating func run() async throws {
        let logger = Logger(label: "Github Example DatabaseBuilder")
        
        // Create event loops for database access
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            Task {
                try await eventLoopGroup.shutdownGracefully()
            }
        }

        do {
            // [SECTION] Delete old files
            
            let databaseFile = URL(filePath: databasePath, directoryHint: .notDirectory)
            let filename = databaseFile.lastPathComponent
            let directory = databaseFile.deletingLastPathComponent()
            
            if FileManager.default.fileExists(atPath: databaseFile.path()) {
                try FileManager.default.removeItem(at: databaseFile)
            }
            let outputShm = directory.appending(component: "\(filename)-shm", directoryHint: .notDirectory)
            if FileManager.default.fileExists(atPath: outputShm.path()) {
                try FileManager.default.removeItem(at: outputShm)
            }
            let outputWal = directory.appending(component: "\(filename)-wal", directoryHint: .notDirectory)
            if FileManager.default.fileExists(atPath: outputWal.path()) {
                try FileManager.default.removeItem(at: outputWal)
            }

            
            // [SECTION] Establish a connection to Postgres
            let pgConfig = PostgresConnection.Configuration(host: "localhost", port: 5432, username: "some-user", password: "secret-password", database: "some-database", tls: .disable)
            
            let conn = try await PostgresConnection.connect(on: eventLoopGroup.any(), configuration: pgConfig, id: 13, logger: logger)
            defer {
                Task {
                    try await conn.close()
                }
            }
            
            // [SECTION] Setup SwiftData
            
            let schema = Schema([
                SimpleModel.self,
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, url:databaseFile, allowsSave: true)
            let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let modelContext = ModelContext(modelContainer)

            
            // [SECTION] Try to migrate a table
            if conn.isClosed {
                print("Postgres connection already closed")
                return
            }
            print("Add data")
            let terms = try await conn.query(
                "SELECT id,name FROM some_table", logger: logger)
            for try await (id, name) in terms.decode((Int64, String).self, context: .default) {
                let newRow = SimpleModel(id: id, name: name)
                modelContext.insert(newRow)
            }
            try modelContext.save()
            
        } catch {
            print("Could not create ModelContainer: \(error)")
        }// end of do
    } // end of run
}

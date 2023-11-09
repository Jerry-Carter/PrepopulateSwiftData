import ArgumentParser
import SQLite

// GOAL: Clear the Write-Ahead-Log for SwiftData databases
//
// PLAN: According to SQLite3 documentation, "The only safe way to remove a WAL file is
// to open the database file using one of the sqlite3_open() interfaces then immediately
// close the database using sqlite3_close()."  Here we open the database, get the version
// to verify that the connection is alive, initiate a vacuum, and then close.  The vacuum
// appears to be needed; otherwise, the WAL file is not deleted.

@main
struct SQLiteCompactor: AsyncParsableCommand {
    static var _commandName = "SQLiteCompactor"
    
    @Argument(help: "Path of the SQLite3 database file to compact")
    var targetDatabase:String
    
    mutating func run() async throws {
        print("Opening database at \(targetDatabase)")
        let db = try Connection(targetDatabase)
        if let version = try db.scalar("SELECT sqlite_version();") {
            print("SQLite version \(version)")
        }
        try db.vacuum()
    }
}

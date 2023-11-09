// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SQLiteCompactor",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "ClientDatabaseBuilder", targets: ["Builder"]),
        .executable(name: "SQLiteCompactor", targets: ["Compactor"]),
    ],
    dependencies: [
        // Excellent framework for writing command line tools in Swift
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.3"),
        
        // Simple Swift interface to SQLite, the database behind SwiftData
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.14.1"),
        
        // Excellent swift interface for PostgreSQL from the Vapor team
        .package(url: "https://github.com/vapor/postgres-nio", from: "1.17.0"),

        // Swift logging package, used by postgres-nio
        // .package(url: "https://github.com/apple/swift-log.git", from: "1.5.3"),
    ],
    targets: [
        // Framework for a tool that will initally populate the SwiftData database
        .executableTarget(
            name: "Builder",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "PostgresNIO", package: "postgres-nio"),
            ],
            exclude: ["Info.plist"],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Sources/Builder/Info.plist",
                ])
            ]
        ),

        // Tool to eliminate the WAL file and compact the database for inclusion
        .executableTarget(
            name: "Compactor",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)

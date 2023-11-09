// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SQLiteCompactor",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "SQLiteCompactor", targets: ["Compactor"]),
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.14.1"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.3"),
    ],
    targets: [
        // Command line tools
        .executableTarget(
            name: "Compactor",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)

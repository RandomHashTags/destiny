// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "destiny",
    products: [
        .library(
            name: "Destiny",
            targets: ["Destiny"]
        ),
    ],
    dependencies: [
        // Macros
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "600.0.0"),

        // Commands
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),

        // Request/Response types
        .package(url: "https://github.com/apple/swift-http-types", from: "1.3.0"),

        // Logging
        .package(url: "https://github.com/apple/swift-log", from: "1.6.1"),

        // Service runtime
        .package(url: "https://github.com/swift-server/swift-service-lifecycle", from: "2.6.1"),

        // Compression
        .package(url: "https://github.com/RandomHashTags/swift-compression", branch: "main")
    ],
    targets: [
        .macro(
            name: "DestinyUtilityMacros",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax")
            ]
        ),
        .target(
            name: "DestinyUtilities",
            dependencies: [
                "DestinyUtilityMacros",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "HTTPTypes", package: "swift-http-types"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "SwiftCompression", package: "swift-compression"),
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax")
            ]
        ),
        .target(
            name: "DestinyDefaults",
            dependencies: [
                "DestinyUtilities",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .target(
            name: "Destiny",
            dependencies: [
                "DestinyMacros",
                "DestinyDefaults",
                "DestinyUtilities",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        
        .macro(
            name: "DestinyMacros",
            dependencies: [
                "DestinyUtilityMacros",
                "DestinyDefaults",
                "DestinyUtilities",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax")
            ]
        ),

        .executableTarget(name: "Run", dependencies: ["Destiny"]),

        .testTarget(
            name: "DestinyTests",
            dependencies: ["Destiny"]
        ),
    ]
)

#if os(Linux)
package.dependencies.append(.package(url: "https://github.com/Kitura/CEpoll", from: "1.0.0"))
#endif
// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "destiny",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "Destiny",
            targets: ["Destiny"]
        ),
    ],
    dependencies: [
        // Macros
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "600.0.0"),
        // Request/Response types
        .package(url: "https://github.com/apple/swift-http-types", from: "1.3.0"),
        // Logging
        .package(url: "https://github.com/apple/swift-log", from: "1.6.1"),
        // Service runtime
        .package(url: "https://github.com/swift-server/swift-service-lifecycle", from: "2.6.1")
    ],
    targets: [
        .target(
            name: "DestinyUtilities",
            dependencies: [
                .product(name: "HTTPTypes", package: "swift-http-types"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle")
            ]
        ),
        .target(
            name: "Destiny",
            dependencies: [
                "DestinyMacros",
                "DestinyUtilities"
            ]
        ),
        
        .macro(
            name: "DestinyMacros",
            dependencies: [
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

// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "destiny",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "Destiny",
            targets: ["Destiny"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "600.0.0"),
        .package(url: "https://github.com/apple/swift-http-types", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "Utilities",
            dependencies: [
                .product(name: "HTTPTypes", package: "swift-http-types")
            ]
        ),
        .target(
            name: "Destiny",
            dependencies: [
                "Utilities",
                "Macros"
            ]
        ),
        
        .macro(
            name: "Macros",
            dependencies: [
                "Utilities",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax")
            ]
        ),

        .testTarget(
            name: "DestinyTests",
            dependencies: ["Destiny"]
        ),
    ]
)

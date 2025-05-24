// swift-tools-version:6.2

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "destiny",
    products: [
        .library(name: "Destiny", targets: ["Destiny"]),
        .library(name: "DestinyBlueprint", targets: ["DestinyBlueprint"]),
        .library(name: "DestinyDefaults", targets: ["DestinyDefaults"])
    ],
    traits: [
        .default(enabledTraits: ["Destiny"]),
        .trait(
            name: "DestinyDefaults",
            description: "Default Destiny features, excluding a functional HTTP Server."
        ),
        .trait(
            name: "Destiny",
            description: "Default Destiny experience with the default features and a functional HTTP Server.",
            enabledTraits: ["DestinyDefaults"]
        )
    ],
    dependencies: [
        // Macros
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "600.0.0"),

        // Commands
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),

        // Logging
        .package(url: "https://github.com/apple/swift-log", from: "1.6.3"),

        // Metrics
        //.package(url: "https://github.com/apple/swift-metrics", from: "2.5.1"),

        // Service runtime
        .package(url: "https://github.com/swift-server/swift-service-lifecycle", from: "2.7.0"),

        // Ordered Dictionary
        .package(url: "https://github.com/apple/swift-collections", from: "1.1.4"),

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

        // MARK: DestinyBlueprint
        .target(
            name: "DestinyBlueprint",
            dependencies: [
                "DestinyUtilityMacros",
                .product(name: "Logging", package: "swift-log"),
                //.product(name: "Metrics", package: "swift-metrics"),
                .product(name: "SwiftCompression", package: "swift-compression"),
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax")
            ]
        ),
        // MARK: DestinyDefaults
        .target(
            name: "DestinyDefaults",
            dependencies: [
                "DestinyBlueprint",
                "DestinyUtilityMacros",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Logging", package: "swift-log"),
                //.product(name: "Metrics", package: "swift-metrics"),
                .product(name: "SwiftCompression", package: "swift-compression"),
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax")
            ]
        ),
        // MARK: Destiny
        .target(
            name: "Destiny",
            dependencies: [
                "DestinyMacros",
                "DestinyDefaults",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        
        .macro(
            name: "DestinyMacros",
            dependencies: [
                "DestinyUtilityMacros",
                "DestinyDefaults",
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
    ],
    swiftLanguageModes: [.v5]
)

#if os(Linux)
package.dependencies.append(.package(url: "https://github.com/Kitura/CEpoll", from: "1.0.0"))
#endif

// TODO: enable the following features: LifetimeDependence
/*
for target in package.targets {
    let lifetimeDependence:SwiftSetting = .enableExperimentalFeature("LifetimeDependence")
    if target.swiftSettings == nil {
        target.swiftSettings = [lifetimeDependence]
    } else {
        target.swiftSettings!.append(contentsOf: [lifetimeDependence])
    }
}*/
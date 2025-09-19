// swift-tools-version:6.2

import PackageDescription
import CompilerPluginSupport

var pkgDependencies:[Package.Dependency] = [
    // Macros
    .package(url: "https://github.com/swiftlang/swift-syntax", from: "601.0.1"),

    // Logging
    .package(url: "https://github.com/apple/swift-log", from: "1.6.3"),

    // Metrics
    //.package(url: "https://github.com/apple/swift-metrics", from: "2.5.1"),

    // Variable-length arrays
    .package(url: "https://github.com/RandomHashTags/swift-variablelengtharray", branch: "main")
]

#if os(Linux)
pkgDependencies.append(contentsOf: [
    // Epoll
    .package(url: "https://github.com/Kitura/CEpoll", from: "1.0.0"),

    // Liburing
    //.package(url: "https://github.com/RandomHashTags/swift-liburing", branch: "main"),
])
#endif

var destinyDependencies:[Target.Dependency] = [
    "DestinyBlueprint",
    "DestinyDefaults",
    .byName(name: "DestinyDefaultsCopyable", condition: .when(traits: ["Copyable"])),
    .byName(name: "DestinyDefaultsNonCopyable", condition: .when(traits: ["NonCopyable"])),
]

#if hasFeature(Embedded)
destinyDependencies.append("DestinyDefaultsGenerics")
#else
destinyDependencies.append("DestinyDefaultsNonEmbedded")
#endif

var destinyMacrosDependencies = destinyDependencies
#if !hasFeature(Embedded)
destinyMacrosDependencies.append("DestinyDefaultsGenerics")
#endif

destinyMacrosDependencies.append(contentsOf: [
    "HTTPHeaderExtras",
    "HTTPMediaTypes",
    "HTTPMediaTypeExtras",
    "HTTPResponseStatusExtras",
    "PerfectHashing",
    .product(name: "SwiftSyntax", package: "swift-syntax"),
    .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
    .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
    .product(name: "SwiftDiagnostics", package: "swift-syntax")
])

let package = Package(
    name: "destiny",
    products: [
        .library(name: "DestinyBlueprint", targets: ["DestinyBlueprint"]),
        .library(name: "DestinyDefaults", targets: ["DestinyDefaults"]),
        .library(name: "DestinyDefaultsCopyable", targets: ["DestinyDefaultsCopyable"]),
        .library(name: "DestinyDefaultsGenerics", targets: ["DestinyDefaultsGenerics"]),
        .library(name: "DestinyDefaultsNonCopyable", targets: ["DestinyDefaultsNonCopyable"]),
        .library(name: "DestinyDefaultsNonEmbedded", targets: ["DestinyDefaultsNonEmbedded"]),
        .library(name: "Destiny", targets: ["Destiny"]),
        .library(name: "DestinySwiftSyntax", targets: ["DestinySwiftSyntax"]),

        .library(name: "HTTPHeaderExtras", targets: ["HTTPHeaderExtras"]),
        .library(name: "HTTPMediaTypes", targets: ["HTTPMediaTypes"]),
        .library(name: "HTTPMediaTypeExtras", targets: ["HTTPMediaTypeExtras"]),
        .library(name: "HTTPResponseStatusExtras", targets: ["HTTPResponseStatusExtras"]),
        .library(name: "PerfectHashing", targets: ["PerfectHashing"])
    ],
    traits: [
        //.default(enabledTraits: []),
        .default(enabledTraits: ["NonCopyable", "Inlinable", "InlineAlways"]),
        //.default(enabledTraits: ["Inlinable", "InlineAlways", "MutableRouter"]),

        .trait( // useful when benchmarking/profiling raw performance
            name: "Inlinable",
            description: "Enables the `@inlinable` annotation for better performance."
        ),
        .trait( // useful when benchmarking/profiling raw performance
            name: "InlineAlways",
            description: "Enables the `@inline(__always)` annotation for better performance."
        ),

        .trait(
            name: "MutableRouter",
            description: "Enables functionality that allows registering data to a Router at runtime."
        ),
        .trait(
            name: "Copyable"
        ),
        .trait(
            name: "NonCopyable"
        ),

        .trait(
            name: "DestinyDefaultsFoundation",
            description: "Foundation extensions to DestinyDefaults."
        ),
        .trait(
            name: "OpenAPI",
            description: "Destiny conformances that enable OpenAPI support."
        ),
    ],
    dependencies: pkgDependencies,
    targets: [
        // MARK: DestinyBlueprint
        .target(
            name: "DestinyBlueprint",
            dependencies: [
                .product(name: "CEpoll", package: "CEpoll", condition: .when(platforms: [.linux])),
                .product(name: "Logging", package: "swift-log"),
                //.product(name: "Metrics", package: "swift-metrics"),
                .product(name: "VariableLengthArray", package: "swift-variablelengtharray")
            ]
        ),

        // MARK: DestinyDefaults
        .target(
            name: "DestinyDefaults",
            dependencies: [
                "DestinyBlueprint",
                .product(name: "Logging", package: "swift-log"),
                //.product(name: "Metrics", package: "swift-metrics"),
            ]
        ),

        // MARK: DestinyDefaultsCopyable
        .target(
            name: "DestinyDefaultsCopyable",
            dependencies: [
                "DestinyDefaults",
                .product(name: "Logging", package: "swift-log"),
                //.product(name: "Metrics", package: "swift-metrics"),
            ]
        ),

        // MARK: DestinyDefaultsCopyable
        .target(
            name: "DestinyDefaultsGenerics",
            dependencies: [
                "DestinyDefaults"
            ]
        ),

        // MARK: DestinyDefaultsNonCopyable
        .target(
            name: "DestinyDefaultsNonCopyable",
            dependencies: [
                "DestinyDefaults",
                .product(name: "Logging", package: "swift-log"),
                //.product(name: "Metrics", package: "swift-metrics"),
            ]
        ),

        // MARK: DestinyDefaultsNonEmbedded
        .target(
            name: "DestinyDefaultsNonEmbedded",
            dependencies: [
                "DestinyBlueprint",
                "DestinyDefaults",
                .product(name: "Logging", package: "swift-log"),
                //.product(name: "Metrics", package: "swift-metrics"),
            ]
        ),

        // MARK: Destiny
        .target(
            name: "Destiny",
            dependencies: destinyDependencies
        ),

        // MARK: DestinySwiftSyntax
        .target(
            name: "DestinySwiftSyntax",
            dependencies: [
                "Destiny",
                "DestinyMacros"
            ]
        ),

        // MARK: HTTPHeaderExtras
        .target(
            name: "HTTPHeaderExtras",
            dependencies: [
                "DestinyDefaults"
            ]
        ),

        // MARK: HTTPMediaTypes
        .target(
            name: "HTTPMediaTypes",
            dependencies: [
                "DestinyBlueprint"
            ]
        ),

        // MARK: HTTPMediaTypeExtras
        .target(
            name: "HTTPMediaTypeExtras",
            dependencies: [
                "HTTPMediaTypes"
            ]
        ),

        // MARK: HTTPResponseStatusExtras
        .target(
            name: "HTTPResponseStatusExtras",
            dependencies: [
                "DestinyDefaults"
            ]
        ),

        // MARK: PerfectHashing
        .target(
            name: "PerfectHashing"
        ),

        // MARK: DestinyMacros
        .macro(
            name: "DestinyMacros",
            dependencies: destinyMacrosDependencies
        ),

        // MARK: TestRouter
        .target(
            name: "TestRouter",
            dependencies: [
                "DestinySwiftSyntax"
            ]
        ),

        .executableTarget(
            name: "Run",
            dependencies: [
                "DestinySwiftSyntax",
                "TestRouter"
            ]
        ),

        .testTarget(
            name: "DestinyTests",
            dependencies: [
                "DestinySwiftSyntax",
                "DestinyMacros",
                "TestRouter"
            ]
        ),
    ]
)

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
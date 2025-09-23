// swift-tools-version:6.2

import PackageDescription
import CompilerPluginSupport

var defaultTraits = Set<String>()

// MARK: Dependencies
var pkgDependencies:[Package.Dependency] = [
    // Macros
    .package(url: "https://github.com/swiftlang/swift-syntax", from: "601.0.1"),

    // Logging
    .package(url: "https://github.com/apple/swift-log", from: "1.6.3"),

    // Metrics
    //.package(url: "https://github.com/apple/swift-metrics", from: "2.5.1"),

    // Variable-length arrays
    .package(url: "https://github.com/RandomHashTags/swift-variablelengtharray", from: "0.2.0", traits: [])
]

#if os(Linux)
pkgDependencies.append(contentsOf: [
    // Epoll
    .package(url: "https://github.com/Kitura/CEpoll", from: "1.0.0"),

    // Liburing
    //.package(url: "https://github.com/RandomHashTags/swift-liburing", branch: "main"),
])

defaultTraits.insert("Epoll")
defaultTraits.insert("Liburing")
#endif

var destinyDependencies:[Target.Dependency] = [
    "DestinyBlueprint",
    "DestinyDefaults",
]

#if !hasFeature(Embedded)
destinyDependencies.append(.byName(name: "DestinyDefaultsNonEmbedded", condition: .when(traits: ["NonEmbedded"])))
#endif

var destinyMacrosDependencies = destinyDependencies

destinyMacrosDependencies.append(contentsOf: [
    "HTTPHeaderExtras",
    "HTTPMediaTypes",
    "HTTPMediaTypeExtras",
    "HTTPRequestMethodExtras",
    "HTTPResponseStatusExtras",
    "PerfectHashing",
    .product(name: "SwiftSyntax", package: "swift-syntax"),
    .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
    .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
    .product(name: "SwiftDiagnostics", package: "swift-syntax")
])

// MARK: Traits
defaultTraits.formUnion([
    //"Generics",
    "GenericDynamicResponse",
    //"MutableRouter", // disabled by default since no other Swift networking library allows that functionality
    "Copyable",
    "NonCopyable",
    "NonEmbedded",
    "PercentEncoding",
    //"RateLimits", // not yet implemented
    "RequestBody",
    "RequestBodyStream",
    "RequestHeaders",
    "StaticMiddleware",

    "Inlinable",
    //"InlineAlways" // disabled by default because it is shown to hurt performance

    //"Epoll",
    //"Liburing",
    "OpenAPI"
])
let traits:Set<Trait> = [
    .default(enabledTraits: defaultTraits),

    .trait(
        name: "GenericHTTPMessage",
        description: "Enables an HTTPMessage implementation utilizing generics, avoiding existentials."
    ),
    .trait(
        name: "GenericStaticRoute",
        description: "Enables a StaticRoute implementation utilizing generics, avoiding existentials."
    ),
    .trait(
        name: "GenericDynamicRoute",
        description: "Enables a DynamicRoute implementation utilizing generics, avoiding existentials."
    ),
    .trait(
        name: "GenericDynamicResponse",
        description: "Enables a DynamicResponse implementation utilizing generics, avoiding existentials.",
        enabledTraits: ["GenericHTTPMessage"]
    ),
    .trait(name: "GenericRouteGroup"),
    .trait(
        name: "Generics",
        description: "Enables all Generic package traits.",
        enabledTraits: [
            "GenericHTTPMessage",
            "GenericStaticRoute",
            "GenericDynamicRoute",
            "GenericDynamicResponse",
            "GenericRouteGroup"
        ]
    ),

    .trait(
        name: "MutableRouter",
        description: "Enables functionality that registers data to a Router at runtime."
    ),
    .trait(
        name: "Copyable"
    ),
    .trait(
        name: "NonCopyable",
        description: "Enables noncopyable functionality for optimal performance."
    ),
    .trait(
        name: "NonEmbedded",
        description: "Enables functionality suitable for non-embedded devices (mainly existentials)."
    ),
    .trait(
        name: "PercentEncoding",
        description: "Enables percent encoding functionality."
    ),
    .trait(
        name: "RateLimits",
        description: "Enables default rate limiting functionality."
    ),
    .trait(
        name: "RequestBody",
        description: "Enables functionality to access a request's body.",
        enabledTraits: ["RequestHeaders"]
    ),
    .trait(
        name: "RequestBodyStream",
        description: "Enables functionality that can stream a request's body.",
        enabledTraits: ["RequestBody"]
    ),
    .trait(
        name: "RequestHeaders",
        description: "Enables functionality to access a request's headers."
    ),
    .trait(
        name: "StaticMiddleware",
        description: "Enables static middleware functionality."
    ),

    .trait( // useful when benchmarking/profiling raw performance
        name: "Inlinable",
        description: "Enables the `@inlinable` annotation where annotated."
    ),
    .trait( // useful when benchmarking/profiling raw performance
        name: "InlineAlways",
        description: "Enables the `@inline(__always)` annotation where annotated."
    ),

    .trait(
        name: "Epoll",
        description: "Enables Epoll functionality (Linux only)."
    ),
    .trait(
        name: "Liburing",
        description: "Enables Liburing functionality (Linux only)."
    ),
    .trait(
        name: "OpenAPI",
        description: "Enables functionality to support OpenAPI."
    )
]

let package = Package(
    name: "destiny",
    products: [
        .library(name: "DestinyBlueprint", targets: ["DestinyBlueprint"]),
        .library(name: "DestinyDefaults", targets: ["DestinyDefaults"]),
        .library(name: "DestinyDefaultsNonEmbedded", targets: ["DestinyDefaultsNonEmbedded"]),
        .library(name: "Destiny", targets: ["Destiny"]),
        .library(name: "DestinySwiftSyntax", targets: ["DestinySwiftSyntax"]),

        .library(name: "HTTPHeaderExtras", targets: ["HTTPHeaderExtras"]),
        .library(name: "HTTPMediaTypes", targets: ["HTTPMediaTypes"]),
        .library(name: "HTTPMediaTypeExtras", targets: ["HTTPMediaTypeExtras"]),
        .library(name: "HTTPRequestMethodExtras", targets: ["HTTPRequestMethodExtras"]),
        .library(name: "HTTPResponseStatusExtras", targets: ["HTTPResponseStatusExtras"]),
        .library(name: "PerfectHashing", targets: ["PerfectHashing"])
    ],
    traits: traits,
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

        // MARK: HTTPRequestMethodExtras
        .target(
            name: "HTTPRequestMethodExtras",
            dependencies: [
                "DestinyDefaults"
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
                "DestinyBlueprint",
                "DestinyDefaults",
                "DestinySwiftSyntax" // comment-out after macro expansion to save binary size
            ]
        ),

        .executableTarget(
            name: "Run",
            dependencies: [
                "DestinyBlueprint",
                "DestinyDefaults",
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
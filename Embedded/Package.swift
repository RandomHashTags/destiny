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

    // Media types
    .package(
        url: "https://github.com/RandomHashTags/swift-media-types",
        from: "0.1.0",
        traits: ["MediaTypes", "RawValues", "FileExtensionInits", "MediaTypeParsable"]
    ),

    // Metrics
    //.package(url: "https://github.com/apple/swift-metrics", from: "2.5.1"),

    // Unlock more performance
    .package(
        url: "https://github.com/RandomHashTags/swift-unwrap-arithmetic-operators",
        from: "0.1.0",
        traits: [
            .trait(name: "UnwrapAddition", condition: .when(traits: ["UnwrapAddition"])),
            .trait(name: "UnwrapSubtraction", condition: .when(traits: ["UnwrapSubtraction"])),
            .trait(name: "UnwrapArithmetic", condition: .when(traits: ["UnwrapArithmetic"]))
        ]
    ),

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
    .product(name: "MediaTypes", package: "swift-media-types", condition: .when(traits: ["MediaTypes"]))
]

var destinyMacrosDependencies = destinyDependencies

destinyMacrosDependencies.append(contentsOf: [
    "PerfectHashing",
    .product(name: "MediaTypesSwiftSyntax", package: "swift-media-types", condition: .when(traits: ["MediaTypes"])),
    .product(name: "SwiftSyntax", package: "swift-syntax"),
    .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
    .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
    .product(name: "SwiftDiagnostics", package: "swift-syntax")
])

// MARK: Traits
defaultTraits.formUnion([
    "Copyable",
    "GenericDynamicResponse",
    "NonCopyable",

    "UnwrapArithmetic",
    "Inlinable",
])
let traits:Set<Trait> = [
    .default(enabledTraits: defaultTraits),

    .trait(
        name: "CORS",
        description: "Enables cross-origin resource sharing functionality."
    ),

    .trait(
        name: "CopyableHTTPServer"
    ),
    .trait(
        name: "CopyableMacroExpansion",
        description: "Enables the copyable MacroExpansion route responder."
    ),
    .trait(
        name: "CopyableMacroExpansionWithDateHeader",
        description: "Enables the copyable MacroExpansionWithDateHeader route responder."
    ),
    .trait(
        name: "CopyableDateHeaderPayload"
    ),
    .trait(
        name: "CopyableStaticStringWithDateHeader",
        enabledTraits: ["CopyableDateHeaderPayload"]
    ),
    .trait(name: "CopyableStringWithDateHeader"),
    .trait(
        name: "CopyableStreamWithDateHeader",
        enabledTraits: ["CopyableDateHeaderPayload"]
    ),
    .trait(
        name: "CopyableResponders",
        description: "Enables all copyable route responders.",
        enabledTraits: [
            "CopyableMacroExpansion",
            "CopyableMacroExpansionWithDateHeader",
            "CopyableStaticStringWithDateHeader",
            "CopyableStringWithDateHeader",
            "CopyableStreamWithDateHeader"
        ]
    ),
    .trait(
        name: "Copyable",
        description: "Enables all copyable package traits.",
        enabledTraits: [
            "CopyableHTTPServer",
            "CopyableResponders"
        ]
    ),

    .trait(name: "NonCopyableHTTPServer"),
    .trait(name: "NonCopyableBytes"),
    .trait(name: "NonCopyableInlineBytes"),
    .trait(name: "NonCopyableDateHeaderPayload"),
    .trait(name: "NonCopyableMacroExpansionWithDateHeader"),
    .trait(
        name: "NonCopyableStaticStringWithDateHeader",
        enabledTraits: ["NonCopyableDateHeaderPayload"]
    ),
    .trait(
        name: "NonCopyableStreamWithDateHeader",
        enabledTraits: ["NonCopyableDateHeaderPayload"]
    ),
    .trait(
        name: "NonCopyableResponders",
        enabledTraits: [
            "NonCopyableBytes",
            "NonCopyableInlineBytes",
            "NonCopyableMacroExpansionWithDateHeader",
            "NonCopyableStaticStringWithDateHeader",
            "NonCopyableStreamWithDateHeader",
        ]
    ),
    .trait(
        name: "NonCopyable",
        description: "Enables noncopyable functionality for optimal performance.",
        enabledTraits: [
            "NonCopyableHTTPServer",
            "NonCopyableResponders"
        ]
    ),

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
    .trait(
        name: "GenericRouteGroup",
        description: "Enables a RouteGroup implementation utilizing generics, avoiding existentials."
    ),
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

    .trait(name: "HTTPNonStandardRequestHeaders"),
    .trait(name: "HTTPNonStandardRequestHeaderHashable"),
    .trait(name: "HTTPNonStandardRequestHeaderRawNames"),
    .trait(name: "HTTPNonStandardRequestHeaderRawValues"),
    .trait(name: "HTTPNonStandardResponseHeaders"),
    .trait(name: "HTTPNonStandardResponseHeaderHashable"),
    .trait(name: "HTTPNonStandardResponseHeaderRawNames"),
    .trait(name: "HTTPNonStandardResponseHeaderRawValues"),
    .trait(name: "HTTPStandardRequestHeaders"),
    .trait(name: "HTTPStandardRequestHeaderHashable"),
    .trait(name: "HTTPStandardRequestHeaderRawNames"),
    .trait(name: "HTTPStandardRequestHeaderRawValues"),
    .trait(name: "HTTPStandardResponseHeaders"),
    .trait(name: "HTTPStandardResponseHeaderHashable"),
    .trait(name: "HTTPStandardResponseHeaderRawNames"),
    .trait(name: "HTTPStandardResponseHeaderRawValues"),
    .trait(
        name: "HTTPRequestHeaders",
        enabledTraits: [
            "HTTPNonStandardRequestHeaders",
            "HTTPNonStandardRequestHeaderHashable",
            "HTTPNonStandardRequestHeaderRawValues",
            "HTTPStandardRequestHeaders",
            "HTTPStandardRequestHeaderHashable",
            "HTTPStandardRequestHeaderRawValues"
        ]
    ),
    .trait(
        name: "HTTPResponseHeaders",
        enabledTraits: [
            "HTTPNonStandardResponseHeaders",
            "HTTPNonStandardResponseHeaderHashable",
            "HTTPNonStandardResponseHeaderRawValues",
            "HTTPStandardResponseHeaders",
            "HTTPStandardResponseHeaderHashable",
            "HTTPStandardResponseHeaderRawValues"
        ]
    ),

    .trait(name: "HTTPNonStandardRequestMethods"),
    .trait(name: "HTTPNonStandardRequestMethodRawValues"),
    .trait(name: "HTTPStandardRequestMethods"),
    .trait(name: "HTTPStandardRequestMethodRawValues"),
    .trait(
        name: "HTTPRequestMethods",
        enabledTraits: [
            "HTTPNonStandardRequestMethods",
            "HTTPNonStandardRequestMethodRawValues",
            "HTTPStandardRequestMethods",
            "HTTPStandardRequestMethodRawValues"
        ]
    ),

    .trait(name: "HTTPNonStandardResponseStatuses"),
    .trait(name: "HTTPNonStandardResponseStatusRawValues"),
    .trait(name: "HTTPStandardResponseStatuses"),
    .trait(name: "HTTPStandardResponseStatusRawValues"),
    .trait(
        name: "HTTPStandardResponseStatuses",
        enabledTraits: [
            "HTTPNonStandardResponseStatuses",
            "HTTPStandardResponseStatuses"
        ]
    ),
    .trait(
        name: "HTTPResponseStatusRawValues",
        enabledTraits: [
            "HTTPNonStandardResponseStatusRawValues",
            "HTTPStandardResponseStatusRawValues"
        ]
    ),

    .trait(
        name: "MutableRouter",
        description: "Enables functionality that registers data to a Router at runtime."
    ),
    .trait(
        name: "NonEmbedded",
        description: "Enables functionality suitable for non-embedded devices (mainly existentials).",
        enabledTraits: [
            "Copyable",
            "RouterSettings",
            "StaticMiddleware",
            "StaticRedirectionRoute"
        ]
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
        name: "RouteGroup",
        enabledTraits: [
            "DynamicResponderStorage",
            "StaticResponderStorage"
        ]
    ),
    .trait(
        name: "RoutePath"
    ),
    .trait(
        name: "RouterSettings"
    ),
    .trait(
        name: "StaticMiddleware",
        description: "Enables static middleware functionality."
    ),
    .trait(
        name: "StaticRedirectionRoute"
    ),

    .trait(name: "DynamicResponderStorage"),
    .trait(name: "StaticResponderStorage"),

    .trait(
        name: "UnwrapAddition",
        description: "Enables unchecked overflow addition operators (`+!` and `+=!`)."
    ),
    .trait(
        name: "UnwrapSubtraction",
        description: "Enables unchecked overflow subtraction operators (`-!` and `-=!`)."
    ),
    .trait(
        name: "UnwrapArithmetic",
        description: "Enables unchecked overflow operators.",
        enabledTraits: [
            "UnwrapAddition",
            "UnwrapSubtraction"
        ]
    ),
    .trait(
        name: "Protocols",
        description: "Enables the design protocols and the DestinyBlueprint target."
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
        name: "Logging",
        description: "Enables swift-log functionality."
    ),
    .trait(
        name: "MediaTypes",
        description: "Enables swift-media-types functionality."
    ),
    .trait(
        name: "OpenAPI",
        description: "Enables functionality to support OpenAPI."
    )
]

let package = Package(
    name: "destiny",
    traits: traits,
    dependencies: pkgDependencies,
    targets: [
        // MARK: Targets





        // MARK: DestinyEmbedded
        .target(
            name: "DestinyEmbedded",
            dependencies: [
                .product(name: "UnwrapArithmeticOperators", package: "swift-unwrap-arithmetic-operators"),
                .product(name: "Logging", package: "swift-log", condition: .when(traits: ["Logging"])),
                .product(name: "VariableLengthArray", package: "swift-variablelengtharray")
            ]
        ),
        // MARK: DestinyBlueprint
        .target(
            name: "DestinyBlueprint",
            dependencies: [
                .product(name: "UnwrapArithmeticOperators", package: "swift-unwrap-arithmetic-operators"),
                "DestinyEmbedded",
                .product(name: "CEpoll", package: "CEpoll", condition: .when(platforms: [.linux])),
                .product(name: "Logging", package: "swift-log", condition: .when(traits: ["Logging"])),
                //.product(name: "Metrics", package: "swift-metrics"),
                .product(name: "VariableLengthArray", package: "swift-variablelengtharray")
            ]
        ),

        // MARK: DestinyDefaults
        .target(
            name: "DestinyDefaults",
            dependencies: [
                .product(name: "UnwrapArithmeticOperators", package: "swift-unwrap-arithmetic-operators"),
                "DestinyEmbedded",
                "DestinyBlueprint",
                .product(name: "Logging", package: "swift-log", condition: .when(traits: ["Logging"])),
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

        // MARK: PerfectHashing
        .target(
            name: "PerfectHashing",
            dependencies: [
                .product(name: "UnwrapArithmeticOperators", package: "swift-unwrap-arithmetic-operators")
            ]
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
                "DestinyEmbedded",
                "DestinyBlueprint",
                "DestinyDefaults",
                //"DestinySwiftSyntax" // TODO: support
            ]
        ),

        .executableTarget(
            name: "Run",
            dependencies: [
                "DestinyEmbedded",
                "DestinyBlueprint",
                "DestinyDefaults",
                "TestRouter"
            ]
        ),
    ]
)
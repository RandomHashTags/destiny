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
    .package(
        url: "https://github.com/RandomHashTags/swift-variablelengtharray",
        from: "0.2.0",
        traits: []
    )
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

var testRouterDependencies:[Target.Dependency] = []

#if !(EMBEDDED || hasFeature(Embedded))
testRouterDependencies.append("DestinySwiftSyntax")
#endif

// MARK: Traits
defaultTraits.formUnion([
    "CORS",
    "Copyable",
    //"Generics", // disabled by default since we use non-embedded types instead of generics by default
    "HTTPCookie",
    "HTTPStandardRequestMethodRawValues",
    "HTTPStandardResponseStatusRawValues",
    "MediaTypes",
    //"MutableRouter", // disabled by default since no other Swift networking library allows that functionality
    "NonCopyable",
    "NonEmbedded",
    "RouterSettings",
    "PercentEncoding",
    //"RateLimits", // not yet implemented
    "RequestBodyStream",
    "RouteGroup",
    //"RoutePath", // not yet integrated
    "StaticMiddleware",
    "StaticRedirectionRoute",

    "StringRequestMethod",
    "StringRouteResponder",
    "UnwrapArithmetic",
    "Protocols",

    "Logging",
    "OpenAPI"
])
let traits:Set<Trait> = [
    .default(enabledTraits: defaultTraits),

    .trait(
        name: "EMBEDDED",
        description: "Enables conditional compilation suitable for embedded mode."
    ),

    .trait(
        name: "StringRequestMethod",
        description: "Makes `String` conform to `HTTPRequestMethodProtocol` for convenience."
    ),
    .trait(
        name: "StringRouteResponder",
        description: "Makes `String` conform to route responder protocols for convenience."
    ),

    .trait(
        name: "CORS",
        description: "Enables cross-origin resource sharing functionality."
    ),

    .trait(
        name: "CopyableDateHeaderPayload"
    ),
    .trait(
        name: "CopyableBytes",
        description: "Enables the copyable Bytes route responder."
    ),
    .trait(
        name: "CopyableInlineBytes",
        description: "Enables the copyable InlineBytes route responder."
    ),
    .trait(
        name: "CopyableMacroExpansion",
        description: "Enables the copyable MacroExpansion route responder."
    ),
    .trait(
        name: "CopyableMacroExpansionWithDateHeader",
        description: "Enables the copyable MacroExpansionWithDateHeader route responder.",
        enabledTraits: ["CopyableDateHeaderPayload"]
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
        name: "Copyable",
        description: "Enables all copyable package traits.",
        enabledTraits: [
            "CopyableBytes",
            "CopyableInlineBytes",
            "CopyableMacroExpansion",
            "CopyableMacroExpansionWithDateHeader",
            "CopyableStaticStringWithDateHeader",
            "CopyableStringWithDateHeader",
            "CopyableStreamWithDateHeader"
        ]
    ),
    
    .trait(name: "NonCopyableHTTPServer"),
    .trait(name: "NonCopyableDateHeaderPayload"),
    .trait(
        name: "NonCopyableBytes",
        description: "Enables the noncopyable Bytes route responder.",
    ),
    .trait(
        name: "NonCopyableInlineBytes",
        description: "Enables the noncopyable InlineBytes route responder.",
    ),
    .trait(
        name: "NonCopyableMacroExpansionWithDateHeader",
        description: "Enables the noncopyable MacroExpansionWithDateHeader route responder.",
        enabledTraits: ["NonCopyableDateHeaderPayload"]
    ),
    .trait(
        name: "NonCopyableStaticStringWithDateHeader",
        description: "Enables the noncopyable StaticStringWithDateHeader route responder.",
        enabledTraits: ["NonCopyableDateHeaderPayload"]
    ),
    .trait(
        name: "NonCopyableStreamWithDateHeader",
        description: "Enables the noncopyable StreamWithDateHeader route responder.",
        enabledTraits: ["NonCopyableDateHeaderPayload"]
    ),
    .trait(
        name: "NonCopyable",
        description: "Enables noncopyable functionality for optimal performance.",
        enabledTraits: [
            "NonCopyableHTTPServer",
            "NonCopyableBytes",
            "NonCopyableInlineBytes",
            "NonCopyableMacroExpansionWithDateHeader",
            "NonCopyableStaticStringWithDateHeader",
            "NonCopyableStreamWithDateHeader"
        ]
    ),

    .trait(
        name: "GenericRouteGroup",
        description: "Enables a RouteGroup implementation utilizing generics, avoiding existentials."
    ),

    .trait(
        name: "HTTPCookie",
        description: "Enables the default HTTPCookie implementation."
    ),

    .trait(name: "HTTPNonStandardRequestHeaders"),
    .trait(
        name: "HTTPNonStandardRequestHeaderHashable",
        enabledTraits: ["HTTPNonStandardRequestHeaders"]
    ),
    .trait(
        name: "HTTPNonStandardRequestHeaderRawNames",
        enabledTraits: ["HTTPNonStandardRequestHeaders"]
    ),
    .trait(
        name: "HTTPNonStandardRequestHeaderRawValues",
        enabledTraits: ["HTTPNonStandardRequestHeaders"]
    ),
    .trait(name: "HTTPNonStandardResponseHeaders"),
    .trait(
        name: "HTTPNonStandardResponseHeaderHashable",
        enabledTraits: ["HTTPNonStandardResponseHeaders"]
    ),
    .trait(
        name: "HTTPNonStandardResponseHeaderRawNames",
        enabledTraits: ["HTTPNonStandardResponseHeaders"]
    ),
    .trait(
        name: "HTTPNonStandardResponseHeaderRawValues",
        enabledTraits: ["HTTPNonStandardResponseHeaders"]
    ),
    .trait(name: "HTTPStandardRequestHeaders"),
    .trait(
        name: "HTTPStandardRequestHeaderHashable",
        enabledTraits: ["HTTPStandardRequestHeaders"]
    ),
    .trait(
        name: "HTTPStandardRequestHeaderRawNames",
        enabledTraits: ["HTTPStandardRequestHeaders"]
    ),
    .trait(
        name: "HTTPStandardRequestHeaderRawValues",
        enabledTraits: ["HTTPStandardRequestHeaders"]
    ),
    .trait(name: "HTTPStandardResponseHeaders"),
    .trait(
        name: "HTTPStandardResponseHeaderHashable",
        enabledTraits: ["HTTPStandardResponseHeaders"]
    ),
    .trait(
        name: "HTTPStandardResponseHeaderRawNames",
        enabledTraits: ["HTTPStandardResponseHeaders"]
    ),
    .trait(
        name: "HTTPStandardResponseHeaderRawValues",
        enabledTraits: ["HTTPStandardResponseHeaders"]
    ),

    .trait(name: "HTTPNonStandardRequestMethods"),
    .trait(
        name: "HTTPNonStandardRequestMethodRawValues",
        enabledTraits: ["HTTPNonStandardRequestMethods"]
    ),
    .trait(name: "HTTPStandardRequestMethods"),
    .trait(
        name: "HTTPStandardRequestMethodRawValues",
        enabledTraits: ["HTTPStandardRequestMethods"]
    ),

    .trait(name: "HTTPNonStandardResponseStatuses"),
    .trait(
        name: "HTTPNonStandardResponseStatusRawValues",
        enabledTraits: ["HTTPNonStandardResponseStatuses"]
    ),
    .trait(name: "HTTPStandardResponseStatuses"),
    .trait(
        name: "HTTPStandardResponseStatusRawValues",
        enabledTraits: ["HTTPStandardResponseStatuses"]
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

    .trait(
        name: "DynamicResponderStorage",
        description: "Enables a responder storage that can register dynamic data to a router at runtime."
    ),
    .trait(
        name: "StaticResponderStorage",
        description: "Enables a responder storage that can register static data to a router at runtime."
    ),

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
        description: "Enables the design protocols."
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

// MARK: Targets
var targets = [





    // MARK: Destiny
    Target.target(
        name: "Destiny",
        dependencies: [
            .product(name: "Logging", package: "swift-log", condition: .when(traits: ["Logging"])),
            .product(name: "MediaTypes", package: "swift-media-types", condition: .when(traits: ["MediaTypes"])),
            .product(name: "UnwrapArithmeticOperators", package: "swift-unwrap-arithmetic-operators"),
            .product(name: "VariableLengthArray", package: "swift-variablelengtharray"),
        ]
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
        dependencies: [
            "Destiny",
            "PerfectHashing",
            .product(name: "MediaTypesSwiftSyntax", package: "swift-media-types", condition: .when(traits: ["MediaTypes"])),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            .product(name: "SwiftDiagnostics", package: "swift-syntax"),
            .product(name: "SwiftSyntax", package: "swift-syntax"),
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax")
        ]
    ),

    // MARK: TestRouter
    .target(
        name: "TestRouter",
        dependencies: [
            "Destiny",
            "DestinySwiftSyntax"
        ]
    ),

    .executableTarget(
        name: "Run",
        dependencies: [
            "Destiny",
            "TestRouter"
        ]
    ),

    .testTarget(
        name: "DestinyTests",
        dependencies: [
            "Destiny",
            "DestinySwiftSyntax",
            "DestinyMacros",
            "TestRouter"
        ]
    ),
]


// MARK: Swift Settings
for target in targets {
    target.swiftSettings = [.enableUpcomingFeature("ExistentialAny")]
}

let package = Package(
    name: "destiny",
    products: [
        .library(name: "Destiny", targets: ["Destiny"]),
        .library(name: "DestinySwiftSyntax", targets: ["DestinySwiftSyntax"]),

        .library(name: "PerfectHashing", targets: ["PerfectHashing"])
    ],
    traits: traits,
    dependencies: pkgDependencies,
    targets: targets
)
// swift-tools-version:6.2

import PackageDescription
import CompilerPluginSupport

let pkgDependencies:[Package.Dependency]
let destinyModuleDependencies:[Target.Dependency]

let swiftSyntaxPackageName: String
let swiftSyntax: (packageName: String, dependency: Package.Dependency)
if false {
    swiftSyntaxPackageName = "fork-swift-syntax"
    swiftSyntax = (
        packageName: swiftSyntaxPackageName,
        dependency: .package(url: "https://github.com/RandomHashTags/\(swiftSyntaxPackageName)", branch: "optimize-codegen-for-ChildNameForKeyPath")
    )
} else {
    swiftSyntaxPackageName = "swift-syntax"
    swiftSyntax = (
        packageName: swiftSyntaxPackageName,
        dependency: .package(url: "https://github.com/swiftlang/\(swiftSyntaxPackageName)", from: "601.0.1")
    )
}

#if os(Linux)
pkgDependencies = [
    // Macros
    swiftSyntax.dependency,

    // Logging
    .package(url: "https://github.com/apple/swift-log", from: "1.6.3"),

    // Metrics
    //.package(url: "https://github.com/apple/swift-metrics", from: "2.5.1"),

    // Epoll
    .package(url: "https://github.com/Kitura/CEpoll", from: "1.0.0")
]

destinyModuleDependencies = [
    "DestinyDefaults",
    .product(name: "CEpoll", package: "CEpoll")
]

#else

pkgDependencies = [
    // Macros
    swiftSyntax.dependency,

    // Logging
    .package(url: "https://github.com/apple/swift-log", from: "1.6.3"),

    // Metrics
    //.package(url: "https://github.com/apple/swift-metrics", from: "2.5.1"),
]

destinyModuleDependencies = [
    "DestinyDefaults"
]

#endif

let package = Package(
    name: "destiny",
    products: [
        .library(name: "DestinyBlueprint", targets: ["DestinyBlueprint"]),
        .library(name: "DestinyDefaults", targets: ["DestinyDefaults"]),
        .library(name: "Destiny", targets: ["Destiny"]),
        .library(name: "DestinySwiftSyntax", targets: ["DestinySwiftSyntax"])
    ],
    traits: [
        .default(enabledTraits: ["Destiny"]),
        .trait(
            name: "DestinyDefaults",
            description: "Default DestinyBlueprint implementations."
        ),
        .trait(
            name: "Destiny",
            description: "Destiny (without Swift Macros)",
            enabledTraits: ["DestinyDefaults"]
        ),
        .trait(
            name: "DestinySwiftSyntax",
            description: "Destiny (with Swift Macros)",
            enabledTraits: ["Destiny"]
        ),

        .trait(
            name: "DestinyDefaultsFoundation",
            description: "Foundation extensions to DestinyDefaults.",
            enabledTraits: ["DestinyDefaults"]
        )
    ],
    dependencies: pkgDependencies,
    targets: [
        // MARK: DestinyBlueprint
        .target(
            name: "DestinyBlueprint",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                //.product(name: "Metrics", package: "swift-metrics")
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

        // MARK: Destiny
        .target(
            name: "Destiny",
            dependencies: destinyModuleDependencies
        ),

        // MARK: DestinySwiftSyntax
        .target(
            name: "DestinySwiftSyntax",
            dependencies: [
                "Destiny",
                "DestinyMacros"
            ]
        ),
        
        .macro(
            name: "DestinyMacros",
            dependencies: [
                "DestinyDefaults",
                .product(name: "SwiftSyntax", package: swiftSyntax.packageName),
                .product(name: "SwiftSyntaxMacros", package: swiftSyntax.packageName),
                .product(name: "SwiftCompilerPlugin", package: swiftSyntax.packageName),
                .product(name: "SwiftDiagnostics", package: swiftSyntax.packageName)
            ]
        ),

        .executableTarget(name: "Run", dependencies: ["DestinySwiftSyntax"]),

        .testTarget(
            name: "DestinyTests",
            dependencies: ["DestinySwiftSyntax"]
        ),
    ],
    swiftLanguageModes: [.v5]
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
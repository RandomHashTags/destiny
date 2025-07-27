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

    // Ordered Dictionary
    .package(url: "https://github.com/apple/swift-collections", from: "1.1.4"),

    // Epoll
    .package(url: "https://github.com/Kitura/CEpoll", from: "1.0.0")
]

destinyModuleDependencies = [
    "DestinyMacros",
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

    // Ordered Dictionary
    .package(url: "https://github.com/apple/swift-collections", from: "1.1.4"),
]

destinyModuleDependencies = [
    "DestinyMacros",
    "DestinyDefaults"
]

#endif

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
    dependencies: pkgDependencies,
    targets: [
        .macro(
            name: "DestinyUtilityMacros",
            dependencies: [
                .product(name: "SwiftSyntax", package: swiftSyntax.packageName),
                .product(name: "SwiftSyntaxMacros", package: swiftSyntax.packageName),
                .product(name: "SwiftCompilerPlugin", package: swiftSyntax.packageName),
                .product(name: "SwiftDiagnostics", package: swiftSyntax.packageName)
            ]
        ),

        // MARK: DestinyBlueprint
        .target(
            name: "DestinyBlueprint",
            dependencies: [
                "DestinyUtilityMacros",
                .product(name: "Logging", package: "swift-log"),
                //.product(name: "Metrics", package: "swift-metrics")
            ]
        ),
        // MARK: DestinyDefaults
        .target(
            name: "DestinyDefaults",
            dependencies: [
                "DestinyBlueprint",
                "DestinyUtilityMacros",
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Logging", package: "swift-log"),
                //.product(name: "Metrics", package: "swift-metrics"),
                .product(name: "SwiftSyntax", package: swiftSyntax.packageName),
                .product(name: "SwiftSyntaxMacros", package: swiftSyntax.packageName)
            ]
        ),
        // MARK: Destiny
        .target(
            name: "Destiny",
            dependencies: destinyModuleDependencies
        ),
        
        .macro(
            name: "DestinyMacros",
            dependencies: [
                "DestinyUtilityMacros",
                "DestinyDefaults",
                .product(name: "SwiftSyntax", package: swiftSyntax.packageName),
                .product(name: "SwiftSyntaxMacros", package: swiftSyntax.packageName),
                .product(name: "SwiftCompilerPlugin", package: swiftSyntax.packageName),
                .product(name: "SwiftDiagnostics", package: swiftSyntax.packageName)
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
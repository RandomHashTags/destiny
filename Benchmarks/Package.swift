// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "Benchmarks",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        // networking
        .package(url: "https://github.com/swift-server/swift-service-lifecycle", exact: "2.9.0"),
        .package(url: "https://github.com/apple/swift-nio", exact: "2.87.0"),
        .package(url: "https://github.com/apple/swift-log", exact: "1.6.4"),

        .package(url: "https://github.com/swift-server/async-http-client", exact: "1.29.0"),

        .package(
            url: "https://github.com/RandomHashTags/destiny",
            branch: "main",
            traits: [
                "Copyable",
                "Inlinable",
                "MediaTypes"
            ]
        ),
        .package(url: "https://github.com/vapor/vapor", exact: "4.117.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird", exact: "2.16.0")
    ],
    targets: [
        .target(
            name: "Utilities",
            dependencies: [
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "AsyncHTTPClient", package: "async-http-client")
            ],
            path: "Benchmarks/Utilities"
        ),

        .target(
            name: "TestDestiny",
            dependencies: [
                "Utilities",
                .product(name: "DestinySwiftSyntax", package: "destiny")
            ],
            path: "Benchmarks/Destiny"
        ),
        .target(
            name: "TestHummingbird",
            dependencies: [
                "Utilities",
                .product(name: "Hummingbird", package: "hummingbird")
            ],
            path: "Benchmarks/Hummingbird"
        ),
        .target(
            name: "TestVapor",
            dependencies: [
                "Utilities",
                .product(name: "Vapor", package: "vapor")
            ],
            path: "Benchmarks/Vapor"
        ),

        .executableTarget(
            name: "Run",
            dependencies: [
                "Utilities",
                "TestDestiny",
                "TestHummingbird",
                "TestVapor"
            ],
            path: "Benchmarks/Run"
        )
    ]
)

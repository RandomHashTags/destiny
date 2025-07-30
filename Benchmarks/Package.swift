// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Benchmarks",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/ordo-one/package-benchmark", from: "1.29.3"),

        // networking
        .package(url: "https://github.com/swift-server/swift-service-lifecycle", from: "2.8.0"),
        .package(url: "https://github.com/apple/swift-nio", from: "2.85.0"),
        .package(url: "https://github.com/apple/swift-log", from: "1.6.4"),

        .package(url: "https://github.com/swift-server/async-http-client", from: "1.26.1"),

        .package(url: "https://github.com/RandomHashTags/destiny", branch: "main"),
        .package(url: "https://github.com/vapor/vapor", exact: "4.115.1"),
        .package(url: "https://github.com/hummingbird-project/hummingbird", exact: "2.15.0")
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

        .testTarget(
            name: "UnitTests",
            dependencies: [
                "Utilities"
            ],
            path: "Benchmarks/UnitTests"
        ),

        .target(
            name: "TestDestiny",
            dependencies: [
                .product(name: "DestinySwiftSyntax", package: "destiny")
            ],
            path: "Benchmarks/Destiny"
        ),
        .target(
            name: "TestHummingbird",
            dependencies: [
                .product(name: "Hummingbird", package: "hummingbird")
            ],
            path: "Benchmarks/Hummingbird"
        ),
        .target(
            name: "TestVapor",
            dependencies: [
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
        ),
        /*.executableTarget(
            name: "Latency",
            dependencies: [
                "Utilities"
            ],
            path: "Benchmarks/Latency"
        ),*/

        /*.executableTarget(
            name: "Benchmarks",
            dependencies: [
                "Utilities",
                
                "TestDestiny",
                "TestHummingbird",
                "TestVapor",
                .product(name: "Benchmark", package: "package-benchmark")
            ],
            path: "Benchmarks/Benchmarks",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark")
            ]
        )*/
    ]
)

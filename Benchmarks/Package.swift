// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Benchmarks",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/ordo-one/package-benchmark", from: "1.27.0"),

        // networking
        .package(url: "https://github.com/swift-server/swift-service-lifecycle", from: "2.0.0"),

        .package(name: "destiny", path: "../"),
        .package(url: "https://github.com/apple/swift-nio", from: "2.75.0"),
        .package(url: "https://github.com/vapor/vapor", from: "4.106.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird", from: "2.1.0")
    ],
    targets: [
        .target(
            name: "Utilities",
            dependencies: [
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle")
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
                .product(name: "Destiny", package: "destiny")
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
        )
    ]
)

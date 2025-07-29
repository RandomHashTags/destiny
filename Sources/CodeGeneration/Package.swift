// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "CodeGeneration",
    products: [
        .executable(
            name: "CodeGeneration",
            targets: ["CodeGeneration"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "601.0.1"),
    ],
    targets: [
        .executableTarget(
            name: "CodeGeneration",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "CodeGenerationTests",
            dependencies: ["CodeGeneration"]
        ),
    ]
)

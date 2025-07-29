// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "CodeGeneration",
    products: [
        .library(
            name: "CodeGeneration",
            targets: ["CodeGeneration"]
        ),
    ],
    targets: [
        .target(
            name: "CodeGeneration"
        ),
        .testTarget(
            name: "CodeGenerationTests",
            dependencies: ["CodeGeneration"]
        ),
    ]
)

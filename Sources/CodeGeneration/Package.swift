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
    targets: [
        .executableTarget(
            name: "CodeGeneration"
        ),
        .testTarget(
            name: "CodeGenerationTests",
            dependencies: ["CodeGeneration"]
        ),
    ]
)

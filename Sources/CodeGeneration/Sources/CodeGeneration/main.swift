
import Foundation

var generationPath = #filePath
generationPath.removeLast("CodeGeneration/Sources/CodeGeneration/main.swift".count)
generationPath += "DestinyDefaults/generated"


let sourceDestination = URL(filePath: generationPath)
try FileManager.default.createDirectory(
    atPath: sourceDestination.path,
    withIntermediateDirectories: true,
    attributes: nil
)

try await withThrowingDiscardingTaskGroup { group in
    group.addTask {
        try await generateHTTPMediaTypes()
    }
    group.addTask {
        try await generateHTTPRequestMethods()
    }
}

func writeToDisk(destination: URL, _ values: [(fileName: String, content: String)]) async throws {
    try FileManager.default.createDirectory(
        atPath: destination.path,
        withIntermediateDirectories: true,
        attributes: nil
    )
    try await withThrowingDiscardingTaskGroup { group in
        for (fileName, content) in values {
            group.addTask {
                let url = destination.appending(component: fileName)
                if FileManager.default.fileExists(atPath: url.path) {
                    let contents = content.data(using: .utf8)
                    FileManager.default.createFile(atPath: url.path, contents: contents)
                } else {
                    try content.write(to: url, atomically: true, encoding: .utf8)
                }
            }
        }
    }
}

func generateHTTPMediaTypes() async throws {
    let destination = sourceDestination.appending(component: "mediaTypes")
    try await writeToDisk(destination: destination, HTTPMediaTypes.generateSources())
}

func generateHTTPRequestMethods() async throws {
    let destination = sourceDestination.appending(component: "requestMethods")
    try await writeToDisk(destination: destination, HTTPRequestMethods.generateSources())
}

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
        try await generateHTTPRequestMethods()
    }
    group.addTask {
        try await generateHTTPResponseStatuses()
    }
    group.addTask {
        try await generateHTTPRequestHeaders()
    }
    group.addTask {
        try await generateHTTPResponseHeaders()
    }
}

func writeToDisk(write: Bool, folder: String, _ values: [(fileName: String, content: String)]) async throws {
    /*guard write else {
        for (fileName, content) in values {
            print("\(fileName)=\n\(content)")
        }
        return
    }*/
    let destination = sourceDestination.appending(component: folder)
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

let actuallyWrite = true

func generateHTTPRequestMethods() async throws {
    try await writeToDisk(write: actuallyWrite, folder: "requestMethods", HTTPRequestMethods.generateSources())
}

func generateHTTPResponseStatuses() async throws {
    try await writeToDisk(write: actuallyWrite, folder: "responseStatuses", HTTPResponseStatuses.generateSources())
}

func generateHTTPRequestHeaders() async throws {
    try await writeToDisk(write: actuallyWrite, folder: "headers", HTTPRequestHeaders.generateSources())
}
func generateHTTPResponseHeaders() async throws {
    try await writeToDisk(write: actuallyWrite, folder: "headers", HTTPResponseHeaders.generateSources())
}
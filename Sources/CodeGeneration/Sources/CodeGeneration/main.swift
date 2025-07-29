
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

try await generateHTTPMediaTypes()

func generateHTTPMediaTypes() async throws {
    let httpMediaTypesDestination = sourceDestination.appending(component: "mediaTypes")
    try FileManager.default.createDirectory(
        atPath: httpMediaTypesDestination.path,
        withIntermediateDirectories: true,
        attributes: nil
    )

    let httpMediaTypes = HTTPMediaTypes.generateSources()
    try await withThrowingDiscardingTaskGroup { group in
        for (fileName, content) in httpMediaTypes {
            group.addTask {
                let url = httpMediaTypesDestination.appending(component: fileName)
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
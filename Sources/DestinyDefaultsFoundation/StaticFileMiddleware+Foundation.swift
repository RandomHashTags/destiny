
import DestinyBlueprint
import DestinyDefaults

#if canImport(FoundationEssentials)
import FoundationEssentials
#elseif canImport(Foundation)
import Foundation
#endif

extension StaticFileMiddleware {
    func routesFoundation(
        version: HTTPVersion,
        method: any HTTPRequestMethodProtocol,
        charset: Charset?,
        path: String,
        endpoint: String
    ) throws -> [StaticRoute] {
        var isDirectory = false
        #if canImport(Darwin)
        var dir:ObjCBool = false
        guard FileManager.default.fileExists(atPath: path, isDirectory: &dir) else { return [] }
        isDirectory = dir.boolValue
        #else
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else { return [] }
        #endif
        if isDirectory {
            let paths = try FileManager.default.contentsOfDirectory(atPath: path)
            print("paths=\(paths)")
            return []
            /*return try paths.flatMap({
                let slug = String($0.split(separator: "/").last ?? "")
                return try routesFoundation(
                    version: version,
                    method: method,
                    charset: charset,
                    supportedCompressionAlgorithms: supportedCompressionAlgorithms,
                    path: $0,
                    endpoint: endpoint + "/" + slug
                )
            })*/
        } else {
            /*let url = URL(filePath: path)
            let contentType = HTTPMediaType.parse(fileExtension: url.pathExtension.lowercased()) ?? HTTPMediaType.textPlain
            let body:ResponseBody = try .data(Data(contentsOf: url))
            var route = StaticRoute(
                version: version,
                method: method,
                path: [],
                status: HTTPResponseStatus.ok,
                contentType: contentType,
                charset: charset,
                body: body,
                supportedCompressionAlgorithms: supportedCompressionAlgorithms
            )
            route.path = endpoint.split(separator: "/").map({ String($0) })
            return [route]*/
            return []
        }
    }
}
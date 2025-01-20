//
//  StaticFileMiddleware.swift
//
//
//  Created by Evan Anderson on 1/12/25.
//

#if canImport(Foundation)
import Foundation
#endif

import DestinyUtilities
import SwiftCompression

// MARK: StaticFileMiddleware
public struct StaticFileMiddleware : FileMiddlewareProtocol {

    let filePath:String
    let endpoint:String

    public init(filePath: String, endpoint: String) {
        self.filePath = filePath
        self.endpoint = endpoint
    }

    public func load() {
    }

    /// - Returns: All the routes associated with the files for the given path.
    public func routes(
        version: HTTPVersion,
        method: HTTPRequestMethod = .get,
        charset: Charset? = .utf8,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm> = []
    ) throws -> [StaticRoute] {
        #if canImport(Foundation)
        return try routesFoundation(version: version, method: method, charset: charset, supportedCompressionAlgorithms: supportedCompressionAlgorithms, path: filePath, endpoint: endpoint)
        #endif
        return []
    }
}

#if canImport(Foundation)
// MARK: Foundation
extension StaticFileMiddleware {
    private func routesFoundation(
        version: HTTPVersion,
        method: HTTPRequestMethod,
        charset: Charset?,
        supportedCompressionAlgorithms: Set<CompressionAlgorithm>,
        path: String,
        endpoint: String
    ) throws -> [StaticRoute] {
        var isDirectory:Bool = false
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else { return [] }
        if isDirectory {
            let paths:[String] = try FileManager.default.contentsOfDirectory(atPath: path)
            print("paths=\(paths)")
            return []
            return try paths.flatMap({
                let slug:String = String($0.split(separator: "/").last ?? "")
                return try routesFoundation(
                    version: version,
                    method: method,
                    charset: charset,
                    supportedCompressionAlgorithms: supportedCompressionAlgorithms,
                    path: $0,
                    endpoint: endpoint + "/" + slug
                )
            })
        } else {
            let url:URL = URL(filePath: path)
            let contentType:HTTPMediaType = HTTPMediaTypes.parse(url.pathExtension.lowercased())?.structure ?? HTTPMediaTypes.Text.plain.structure
            let result:RouteResult = try .data(Data(contentsOf: url))
            var route:StaticRoute = StaticRoute(
                version: version,
                method: method,
                path: [],
                status: .ok,
                contentType: contentType,
                charset: charset,
                result: result,
                supportedCompressionAlgorithms: supportedCompressionAlgorithms
            )
            route.path = endpoint.split(separator: "/").map({ String($0) })
            return [route]
        }
    }
}
#endif
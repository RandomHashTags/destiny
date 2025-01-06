//
//  DestinyTests.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

#if compiler(>=6.0)

import Destiny
import HTTPTypes
import SwiftCompression
import Testing

struct DestinyTests {
    @Test func memoryLayouts() {
        //print(layout(for: RouteProtocol.self))
        //print("from: \(layout(for: Test1.self))")
        //print("to: \(layout(for: DynamicRoute.self))")
    }
    func layout<T>(for type: T.Type) -> (Int, Int, Int) {
        return (
            MemoryLayout<T>.alignment,
            MemoryLayout<T>.size,
            MemoryLayout<T>.stride
        )
    }

    struct Test1 {
        public let version:HTTPVersion
        public var method:HTTPRequestMethod
        public var path:[PathComponent]
        public var status:HTTPResponse.Status
        public var contentType:HTTPMediaType
        public var defaultResponse:DynamicResponseProtocol
        public var supportedCompressionAlgorithms:Set<CompressionAlgorithm>
        public let handler:@Sendable (_ request: inout RequestProtocol, _ response: inout DynamicResponseProtocol) async throws -> Void
        var handlerLogic:String = "{ _, _ in }"
    }

    @Test func example() {
        let _:Router = #router(
            version: .v2_0,
            middleware: [
                StaticMiddleware(handlesMethods: [.get], handlesContentTypes: [HTTPMediaTypes.Text.html], appliesStatus: .ok, appliesHeaders: ["Are-You-My-Brother":"yes"])
            ],
            StaticRoute(
                method: .get,
                path: ["test1"],
                contentType: HTTPMediaTypes.Text.html,
                charset: Charset.utf8,
                result: .staticString("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>")
            ),
            StaticRoute(
                method: .get,
                path: ["test2"],
                status: .movedPermanently,
                contentType: HTTPMediaTypes.Text.html,
                charset: .utf8,
                result: .staticString("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>")
            ),
            StaticRoute(
                method: .get,
                path: ["test3"],
                contentType: HTTPMediaTypes.Text.html,
                charset: .utf8,
                result: .bytes([UInt8]("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>".utf8))
            ),
            StaticRoute(
                method: .get,
                path: ["test4"],
                contentType: HTTPMediaTypes.Text.html,
                charset: .utf8,
                result: .bytes16([UInt16]("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>".utf16))
            )
        )
    }
}

#endif
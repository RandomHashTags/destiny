//
//  DestinyTests.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Destiny
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
        public var status:HTTPResponseStatus
        public var contentType:HTTPMediaType
        public var defaultResponse:any DynamicResponseProtocol
        public var supportedCompressionAlgorithms:Set<CompressionAlgorithm>
        public let handler:@Sendable (_ request: inout any RequestProtocol, _ response: inout any DynamicResponseProtocol) async throws -> Void
        var handlerLogic:String = "{ _, _ in }"
    }

    @Test func example() {
        let _:DefaultRouter = #router(
            version: .v2_0,
            middleware: [
                StaticMiddleware(handlesMethods: [.get], handlesContentTypes: [HTTPMediaType.textHtml], appliesStatus: HTTPResponseStatus.ok.code, appliesHeaders: ["Are-You-My-Brother":"yes"])
            ],
            StaticRoute(
                method: .get,
                path: ["test1"],
                contentType: HTTPMediaType.textHtml,
                charset: Charset.utf8,
                result: .staticString("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>")
            ),
            StaticRoute(
                method: .get,
                path: ["test2"],
                status: HTTPResponseStatus.movedPermanently,
                contentType: HTTPMediaType.textHtml,
                charset: .utf8,
                result: .staticString("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>")
            ),
            StaticRoute(
                method: .get,
                path: ["test3"],
                contentType: HTTPMediaType.textHtml,
                charset: .utf8,
                result: .bytes([UInt8]("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>".utf8))
            ),
            StaticRoute(
                method: .get,
                path: ["test4"],
                contentType: HTTPMediaType.textHtml,
                charset: .utf8,
                result: .bytes16([UInt16]("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>".utf16))
            )
        )
    }
}
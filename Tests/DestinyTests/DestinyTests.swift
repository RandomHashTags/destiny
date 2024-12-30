//
//  DestinyTests.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

#if compiler(>=6.0)

import Destiny
import HTTPTypes
import Testing

struct DestinyTests {
    @Test func memoryLayouts() {
        //print(layout(for: HTTPMediaTypes.Application.self))
    }
    func layout<T>(for type: T.Type) -> (Int, Int, Int) {
        return (
            MemoryLayout<T>.alignment,
            MemoryLayout<T>.size,
            MemoryLayout<T>.stride
        )
    }

    struct Test1 {
        var version:HTTPVersion
        var status:HTTPResponse.Status
        var headers:[String:String]
        var result:RouteResult?
        var contentType:HTTPMediaType?
        var charset:String?
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
                charset: "UTF-8",
                result: .string("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>")
            ),
            StaticRoute(
                method: .get,
                path: ["test2"],
                status: .movedPermanently,
                contentType: HTTPMediaTypes.Text.html,
                charset: "UTF-8",
                result: .string("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>")
            ),
            StaticRoute(
                returnType: .uint8Array,
                method: .get,
                path: ["test3"],
                contentType: HTTPMediaTypes.Text.html,
                charset: "UTF-8",
                result: .string("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>")
            ),
            StaticRoute(
                returnType: .uint16Array,
                method: .get,
                path: ["test"],
                contentType: HTTPMediaTypes.Text.html,
                charset: "UTF-8",
                result: .string("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>")
            )
        )
    }
}

#endif
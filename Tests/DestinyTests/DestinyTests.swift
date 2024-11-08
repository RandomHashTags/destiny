//
//  DestinyTests.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Destiny
import DestinyUtilities
import HTTPTypes
import Testing

struct DestinyTests {
    @Test func example() {
        let _:Router = #router(
            version: "HTTP/2.0",
            middleware: [
                StaticMiddleware(handlesMethods: [.get], handlesContentTypes: [HTTPMediaType.Text.html], appliesStatus: .ok, appliesHeaders: ["Are-You-My-Brother":"yes"])
            ],
            StaticRoute(
                method: .get,
                path: ["test1"],
                contentType: HTTPMediaType.Text.html,
                charset: "UTF-8",
                result: .string("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>")
            ),
            StaticRoute(
                method: .get,
                path: ["test2"],
                status: .movedPermanently,
                contentType: HTTPMediaType.Text.html,
                charset: "UTF-8",
                result: .string("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>")
            ),
            StaticRoute(
                returnType: .uint8Array,
                method: .get,
                path: ["test3"],
                contentType: HTTPMediaType.Text.html,
                charset: "UTF-8",
                result: .string("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>")
            ),
            StaticRoute(
                returnType: .uint16Array,
                method: .get,
                path: ["test"],
                contentType: HTTPMediaType.Text.html,
                charset: "UTF-8",
                result: .string("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>")
            )
        )
    }
}
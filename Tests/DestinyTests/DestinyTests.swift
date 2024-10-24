//
//  DestinyTests.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Testing

import HTTPTypes

import Destiny
import DestinyUtilities

struct DestinyTests {
    @Test func example() {
        var stack_string32:StackString32 = StackString32()
        for i in 0..<StackString32.scalarCount {
            stack_string32[i] = UInt8(65 + i)
        }
        stack_string32[15] = 32 // space
        let values:[StackString32] = stack_string32.split(separator: 32)
        for value in values {
            print(value.description + " \(value)")
        }

        var string:String = "test"
        let test:StackString32 = StackString32(&string)
        print("test=\(test)")
        return;

        let static_string_router:Router = #router(
            returnType: .staticString,
            version: "HTTP/2.0",
            middleware: [
                StaticMiddleware(appliesToMethods: [.get], appliesToContentTypes: [.html], appliesStatus: .ok, appliesHeaders: ["Are-You-My-Brother":"yes"])
            ],
            Route(
                method: .get,
                path: "test",
                contentType: .html,
                charset: "UTF-8",
                staticResult: .string("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>"),
                dynamicResult: nil
            )
        )
        let static_string_router2:Router = #router(
            returnType: .staticString,
            version: "HTTP/2.0",
            middleware: [
                StaticMiddleware(appliesToMethods: [.get], appliesToContentTypes: [.html], appliesStatus: .ok, appliesHeaders: ["Are-You-My-Brother":"yes"])
            ],
            Route(
                method: .get,
                path: "test",
                status: .movedPermanently,
                contentType: .html,
                charset: "UTF-8",
                staticResult: .string("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>"),
                dynamicResult: nil
            )
        )
        let uint8Array_router:Router = #router(
            returnType: .uint8Array,
            version: "HTTP/2.0",
            middleware: [
                StaticMiddleware(appliesToMethods: [.get], appliesToContentTypes: [.html], appliesStatus: .ok, appliesHeaders: ["Are-You-My-Brother":"yes"])
            ],
            Route(
                method: .get,
                path: "test",
                contentType: .html,
                charset: "UTF-8",
                staticResult: .string("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>"),
                dynamicResult: nil
            )
        )
        let uint16Array_router:Router = #router(
            returnType: .uint16Array,
            version: "HTTP/2.0",
            middleware: [
                StaticMiddleware(appliesToMethods: [.get], appliesToContentTypes: [.html], appliesStatus: .ok, appliesHeaders: ["Are-You-My-Brother":"yes"])
            ],
            Route(
                method: .get,
                path: "test",
                contentType: .html,
                charset: "UTF-8",
                staticResult: .string("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>"),
                dynamicResult: nil
            )
        )
    }
}
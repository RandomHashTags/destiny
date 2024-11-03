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
    @Test func simd_leadingNonzeroByteCount() {
        var string:String = "siuerbnieprsbgsrgnpeirfnpae"
        var ss32:StackString32 = StackString32(&string)
        #expect(ss32.leadingNonzeroByteCount == 27)

        string = "ouerb\0gouwrgoruegbrotugbrotgenrotgurteg"
        ss32 = StackString32(&string)
        #expect(ss32.leadingNonzeroByteCount == 5)

        string = ""
        var ss2:StackString2 = StackString2(&string)
        #expect(ss2.leadingNonzeroByteCount == 0)

        string = "a"
        ss2 = StackString2(&string)
        #expect(ss2.leadingNonzeroByteCount == 1)
    }
    @Test func simd_hasPrefix() {
        var string:String = "testing brother!?!"
        let test:StackString32 = StackString32(&string)
        #expect(test.hasPrefix(SIMD2<UInt8>(x: Character("t").asciiValue!, y: Character("e").asciiValue!)))
        #expect(test.hasPrefix(SIMD4<UInt8>(Character("t").asciiValue!, Character("e").asciiValue!, Character("s").asciiValue!, Character("t").asciiValue!)))
        #expect(test.hasPrefix(SIMD8<UInt8>(Character("t").asciiValue!, Character("e").asciiValue!, Character("s").asciiValue!, Character("t").asciiValue!, Character("i").asciiValue!, Character("n").asciiValue!, Character("g").asciiValue!, Character(" ").asciiValue!)))
        #expect(test.hasPrefix(SIMD16<UInt8>(
            Character("t").asciiValue!,
            Character("e").asciiValue!,
            Character("s").asciiValue!,
            Character("t").asciiValue!,
            Character("i").asciiValue!,
            Character("n").asciiValue!,
            Character("g").asciiValue!,
            Character(" ").asciiValue!,
            Character("b").asciiValue!,
            Character("r").asciiValue!,
            Character("o").asciiValue!,
            Character("t").asciiValue!,
            Character("h").asciiValue!,
            Character("e").asciiValue!,
            Character("r").asciiValue!,
            Character("!").asciiValue!
        )))
    }
    @Test func simd_split4() throws {
        let ss:StackString4 = StackString4(31, 32, 33, 34)
        var values:[StackString4] = ss.split(separator: 32)

        try #require(values.count == 2, Comment(rawValue: "\(values)"))
        #expect(values[0] == SIMD4(31, 0, 0, 0))
        #expect(values[1] == SIMD4(33, 34, 0, 0))

        values = ss.split(separator: 35)
        try #require(values.count == 1)
        #expect(values[0] == ss)

        values = ss.split(separator: 33)
        try #require(values.count == 2, Comment(rawValue: "\(values)"))
        #expect(values[0] == SIMD4(31, 32, 0 ,0))
        #expect(values[1] == SIMD4(34, 0, 0, 0))

        values = ss.split(separator: 34)
        try #require(values.count == 1, Comment(rawValue: "\(values)"))
        #expect(values[0] == SIMD4(31, 32, 33, 0))

        values = ss.split(separator: 31)
        try #require(values.count == 1, Comment(rawValue: "\(values)"))
        #expect(values[0] == SIMD4(32, 33, 34, 0))
    }
    @Test func simd_string() throws {
        var string:String = "brooooooooo !"
        let ss:StackString64 = StackString64(&string)
        #expect(ss.string() == "brooooooooo !")
    }
    @Test func example() {
        let static_string_router:Router = #router(
            returnType: .staticString,
            version: "HTTP/2.0",
            middleware: [
                StaticMiddleware(handlesMethods: [.get], handlesContentTypes: [.html], appliesStatus: .ok, appliesHeaders: ["Are-You-My-Brother":"yes"])
            ],
            StaticRoute(
                method: .get,
                path: ["test"],
                contentType: .html,
                charset: "UTF-8",
                result: .string("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>")
            )
        )
        let static_string_router2:Router = #router(
            returnType: .staticString,
            version: "HTTP/2.0",
            middleware: [
                StaticMiddleware(handlesMethods: [.get], handlesContentTypes: [.html], appliesStatus: .ok, appliesHeaders: ["Are-You-My-Brother":"yes"])
            ],
            StaticRoute(
                method: .get,
                path: ["test"],
                status: .movedPermanently,
                contentType: .html,
                charset: "UTF-8",
                result: .string("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>")
            )
        )
        let uint8Array_router:Router = #router(
            returnType: .uint8Array,
            version: "HTTP/2.0",
            middleware: [
                StaticMiddleware(handlesMethods: [.get], handlesContentTypes: [.html], appliesStatus: .ok, appliesHeaders: ["Are-You-My-Brother":"yes"])
            ],
            StaticRoute(
                method: .get,
                path: ["test"],
                contentType: .html,
                charset: "UTF-8",
                result: .string("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>")
            )
        )
        let uint16Array_router:Router = #router(
            returnType: .uint16Array,
            version: "HTTP/2.0",
            middleware: [
                StaticMiddleware(handlesMethods: [.get], handlesContentTypes: [.html], appliesStatus: .ok, appliesHeaders: ["Are-You-My-Brother":"yes"])
            ],
            StaticRoute(
                method: .get,
                path: ["test"],
                contentType: .html,
                charset: "UTF-8",
                result: .string("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>")
            )
        )
    }
}
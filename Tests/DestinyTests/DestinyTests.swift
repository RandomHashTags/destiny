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
    @Test func example() {
        var stack_string32:StackString32 = StackString32()
        for i in 0..<StackString32.scalarCount {
            stack_string32[i] = UInt8(65 + i)
        }
        stack_string32[15] = 32 // space
        let values:[StackString32] = stack_string32.split(separator: 32)
        #expect(values.count == 2)
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
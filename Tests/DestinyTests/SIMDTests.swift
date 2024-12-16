//
//  SIMDTests.swift
//
//
//  Created by Evan Anderson on 11/8/24.
//

#if compiler(>=6.0)

import DestinyUtilities
import Testing

struct SIMDTests {
    // MARK: leadingNonzeroByteCount
    @Test func leadingNonzeroByteCount() {
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

    // MARK: leadingNonByteCount
    @Test func leadingNonByteCount() {
        var string:String = "siuerbnieprsbgsrgnpeirfnpae"
        var ss32:StackString32 = StackString32(&string)
        #expect(ss32.leadingNonByteCount(byte: 92) == 32)

        string = "ouerb\\gouwrgoruegbrotugbrotgenrotgurteg"
        ss32 = StackString32(&string)
        #expect(ss32.leadingNonByteCount(byte: 92) == 5)
    }

    // MARK: trailingNonzeroByteCount
    @Test func trailingNonzeroByteCount() {
        var string:String = "siuerbnieprsbgsrgnpeirfnpae"
        var ss32:StackString32 = StackString32(&string)
        #expect(ss32.trailingNonzeroByteCount == 0)

        string = "ouerbgouwrgoruegbrotugbtg\0enrotg"
        ss32 = StackString32(&string)
        #expect(ss32.trailingNonzeroByteCount == 6)

        string = ""
        var ss2:StackString2 = StackString2(&string)
        #expect(ss2.trailingNonzeroByteCount == 0)

        string = "a"
        ss2 = StackString2(&string)
        #expect(ss2.trailingNonzeroByteCount == 0)
    }

    // MARK: trailingZeroByteCount
    @Test func trailingZeroByteCount() {
        var string:String = "siuerbnieprsbgsrgnpeirfnpae"
        var ss32:StackString32 = StackString32(&string)
        #expect(ss32.trailingZeroByteCount == 5)

        string = "ouerbgouwrgoruegbrotugbtg\0enrotg"
        ss32 = StackString32(&string)
        #expect(ss32.trailingZeroByteCount == 0)

        string = ""
        var ss2:StackString2 = StackString2(&string)
        #expect(ss2.trailingZeroByteCount == 2, Comment(rawValue: ss2.leadingString()))

        string = "a"
        ss2 = StackString2(&string)
        #expect(ss2.trailingZeroByteCount == 1, Comment(rawValue: ss2.leadingString()))
    }

    // MARK: hasPrefix
    @Test func hasPrefix() {
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

    // MARK: split
    @Test func split() throws {
        var string:String = "GET /dynamic/text HTTP/1.1"
        var ss:StackString32 = StackString32(&string)
        var values:[StackString32] = ss.splitSIMD(separator: 32) // space
        try #require(values.count == 3)
        #expect(values[0].leadingString() == "GET")
        #expect(values[1].leadingString() == "/dynamic/text")
        #expect(values[2].leadingString() == "HTTP/1.1")
    }

    // MARK: split4
    @Test func split4() throws {
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

    // MARK: string
    @Test func leadingString() {
        var string:String = "brooooooooo !"
        let ss:StackString64 = StackString64(&string)
        #expect(ss.leadingString() == "brooooooooo !")
    }

    // MARK: dropTrailing
    @Test func dropTrailing() {
        var string:String = "iuebrgow eg347h0t34h t30834r034rgg3q 632 q  0928j3 m939n3 4580tw"
        var ss64:StackString64 = StackString64(&string)
        ss64.dropTrailing(1)
        #expect(ss64.leadingString() == "iuebrgow eg347h0t34h t30834r034rgg3q 632 q  0928j3 m939n3 4580t")

        ss64.dropTrailing(5)
        #expect(ss64.leadingString() == "iuebrgow eg347h0t34h t30834r034rgg3q 632 q  0928j3 m939n3 4")

        ss64.dropTrailing(32)
        #expect(ss64.leadingString() == "iuebrgow eg347h0t34h t30834r034r")
    }

    // MARK: keepLeading
    @Test func keepLeading() {
        var string:String = "iuebrgow eg347h0t34h t30834r034rgg3q 632 q  0928j3 m939n3 4580tw"
        var ss64:StackString64 = StackString64(&string)
        ss64.keepLeading(35)
        #expect(ss64.leadingString() == "iuebrgow eg347h0t34h t30834r034rgg3")

        ss64.keepLeading(31)
        #expect(ss64.leadingString() == "iuebrgow eg347h0t34h t30834r034")

        ss64.keepLeading(14)
        #expect(ss64.leadingString() == "iuebrgow eg347")

        ss64.keepLeading(8)
        #expect(ss64.leadingString() == "iuebrgow")

        ss64.keepLeading(7)
        #expect(ss64.leadingString() == "iuebrgo")

        ss64.keepLeading(6)
        #expect(ss64.leadingString() == "iuebrg")

        ss64.keepLeading(5)
        #expect(ss64.leadingString() == "iuebr")

        ss64.keepLeading(4)
        #expect(ss64.leadingString() == "iueb")

        ss64.keepLeading(3)
        #expect(ss64.leadingString() == "iue")
    }

    // MARK: keepTrailing
    @Test func keepTrailing() {
        var string:String = "iuebrgow eg347h0t34h t30834r034rgg3q 632 q  0928j3 m939n3 4580tw"
        var ss64:StackString64 = StackString64(&string)
        ss64.keepTrailing(35)
        #expect(ss64.trailingString() == "34rgg3q 632 q  0928j3 m939n3 4580tw")

        ss64.keepTrailing(31)
        #expect(ss64.trailingString() == "g3q 632 q  0928j3 m939n3 4580tw")

        ss64.keepTrailing(14)
        #expect(ss64.trailingString() == " m939n3 4580tw")

        ss64.keepTrailing(8)
        #expect(ss64.trailingString() == "3 4580tw")

        ss64.keepTrailing(7)
        #expect(ss64.trailingString() == " 4580tw")

        ss64.keepTrailing(6)
        #expect(ss64.trailingString() == "4580tw")

        ss64.keepTrailing(5)
        #expect(ss64.trailingString() == "580tw")

        ss64.keepTrailing(4)
        #expect(ss64.trailingString() == "80tw")

        ss64.keepTrailing(3)
        #expect(ss64.trailingString() == "0tw")
    }
}

#endif
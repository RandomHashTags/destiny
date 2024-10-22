//
//  StackStrings.swift
//
//
//  Created by Evan Anderson on 10/22/24.
//

// MARK: StackString
public protocol StackStringProtocol : Sendable, Hashable, CustomStringConvertible {
    static var size : Int { get }

    associatedtype BufferType
    var buffer : BufferType { get set }

    init()
    init(_ buffer: BufferType)
    init(_ characters: UInt8...)
    init(_ string: inout String)

    subscript(_ index: Int) -> UInt8 { get set }
}
@attached(member, names: named(buffer), arbitrary)
public macro StackString(bufferLength: Int) = #externalMacro(module: "Macros", type: "StackString")

// MARK: StackString4
@StackString(bufferLength: 4)
public struct StackString4 : StackStringProtocol {
}

// MARK: StackString8
@StackString(bufferLength: 8)
public struct StackString8 : StackStringProtocol {
}

// MARK: StackString16
@StackString(bufferLength: 16)
public struct StackString16 : StackStringProtocol {
}

// MARK: StackString32
@StackString(bufferLength: 32)
public struct StackString32 : StackStringProtocol {
}

// MARK: StackString64
@StackString(bufferLength: 64)
public struct StackString64 : StackStringProtocol {
}

// MARK: StackString128
@StackString(bufferLength: 128)
public struct StackString128 : StackStringProtocol {
}

// MARK: StackString256
@StackString(bufferLength: 256)
public struct StackString256 : StackStringProtocol {
}

// MARK: StackString24
@StackString(bufferLength: 24)
public struct StackString24 : StackStringProtocol {
}

// MARK: StackString48
@StackString(bufferLength: 48)
public struct StackString48 : StackStringProtocol {
}

// MARK: StackString96
@StackString(bufferLength: 96)
public struct StackString96 : StackStringProtocol {
}

// MARK: StackString192
@StackString(bufferLength: 192)
public struct StackString192 : StackStringProtocol {
}
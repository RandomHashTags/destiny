//
//  StackStrings.swift
//
//
//  Created by Evan Anderson on 10/22/24.
//

// MARK: StackString
public protocol StackStringProtocol : Sendable, Hashable, CustomStringConvertible {
    /// The number of bytes this StackString holds.
    static var size : Int { get }

    associatedtype BufferType
    var buffer : BufferType { get set }

    /// Creates an empty StackString.
    init()
    init(_ buffer: BufferType)
    init(_ characters: UInt8...)
    init(_ string: inout String)

    /// The number of non-zero leading bytes this StackString has.
    /// - Complexity: O(_n_) where _n_ is this StackString's size.
    var count : Int { get }

    subscript(_ index: Int) -> UInt8 { get set }
}
@attached(member, names: named(buffer), arbitrary)
public macro StackString(bufferLength: Int) = #externalMacro(module: "Macros", type: "StackString")

public typealias StackString2 = SIMD2<UInt8>
public typealias StackString4 = SIMD4<UInt8>
public typealias StackString8 = SIMD8<UInt8>
public typealias StackString16 = SIMD16<UInt8>
public typealias StackString32 = SIMD32<UInt8>
public typealias StackString64 = SIMD64<UInt8>

public extension SIMD where Scalar : BinaryInteger {
    init(_ string: inout String) {
        var item:Self = Self()
        string.withUTF8 { p in
            for i in 0..<Swift.min(p.count, Self.scalarCount) {
                item[i] = Scalar(p[i])
            }
        }
        self = item
    }

    var leadingZeroByteCount : Int {
        var amount:Int = 0
        for i in 0..<scalarCount {
            if self[i] == 0 {
                amount = i
                break
            }
        }
        return amount
    }

    func hasPrefix<T: SIMD>(_ simd: T) -> Bool where T.Scalar: BinaryInteger, Scalar == T.Scalar {
        var copy:T = T()
        for i in 0..<T.scalarCount {
            copy[i] = self[i]
        }
        return simd == copy
    }
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
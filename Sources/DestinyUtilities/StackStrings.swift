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

    /// - Complexity: O(_n_) where _n_ equals `scalarCount`
    var leadingNonzeroByteCount : Int {
        for i in 0..<scalarCount {
            if self[i] == 0 {
                return i
            }
        }
        return 0
    }

    func hasPrefix<T: SIMD>(_ simd: T) -> Bool where T.Scalar: BinaryInteger, Scalar == T.Scalar {
        var nibble:T = T()
        for i in 0..<T.scalarCount {
            nibble[i] = self[i]
        }
        return nibble == simd
    }

    func split(separator: Scalar) -> [Self] {
        var anchor:Int = 0, array:[Self] = []
        array.reserveCapacity(2)
        for i in 0..<scalarCount {
            if self[i] == separator {
                var slice:Self = Self(), slice_index:Int = 0
                if anchor != 0 {
                    anchor += 1
                }
                if anchor < i {
                    for j in anchor..<i {
                        slice[slice_index] = self[anchor + j]
                        slice_index += 1
                    }
                    if slice_index != 0 {
                        array.append(slice)
                    }
                    anchor = i
                }
            }
        }
        if array.isEmpty {
            return [self]
        }
        var ending_slice:Self = Self(), slice_index:Int = 0
        if anchor != 0 {
            anchor += 1
        }
        for i in anchor..<scalarCount {
            ending_slice[slice_index] = self[i]
            slice_index += 1
        }
        array.append(ending_slice)
        return array
    }
}

/*
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
}*/
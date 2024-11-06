//
//  StackStrings.swift
//
//
//  Created by Evan Anderson on 10/22/24.
//

public typealias StackString2 = SIMD2<UInt8>
public typealias StackString4 = SIMD4<UInt8>
public typealias StackString8 = SIMD8<UInt8>
public typealias StackString16 = SIMD16<UInt8>
public typealias StackString32 = SIMD32<UInt8>
public typealias StackString64 = SIMD64<UInt8>

public extension SIMD where Scalar : BinaryInteger {
    /// - Complexity: O(_n_), where _n_ equals the lesser of `string.count` & `scalarCount`.
    init(_ string: inout String) {
        var item:Self = Self()
        string.withUTF8 { p in
            for i in 0..<Swift.min(p.count, Self.scalarCount) {
                item[i] = Scalar(p[i])
            }
        }
        self = item
    }

    /// - Complexity: O(_n_), where _n_ equals `scalarCount`.
    var leadingNonzeroByteCountSIMD : Int {
        for i in 0..<scalarCount {
            if self[i] == 0 {
                return i
            }
        }
        return scalarCount
    }

    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(_n_), where _n_ equals the target SIMD's `scalarCount`.
    func hasPrefixSIMD<T: SIMD>(_ simd: T) -> Bool where T.Scalar: BinaryInteger, Scalar == T.Scalar {
        var nibble:T = T()
        for i in 0..<T.scalarCount {
            nibble[i] = self[i]
        }
        return nibble == simd
    }

    /// - Complexity: O(_n_), where _n_ equals `scalarCount`.
    func splitSIMD(separator: Scalar) -> [Self] { // TODO: make SIMD fast
        var anchor:Int = 0, array:[Self] = []
        array.reserveCapacity(2)
        for i in 0..<scalarCount {
            if self[i] == separator {                
                if anchor < i {
                    var slice:Self = Self(), slice_index:Int = 0
                    for j in anchor..<i {
                        slice[slice_index] = self[j]
                        slice_index += 1
                    }
                    if slice_index != 0 {
                        array.append(slice)
                    }
                }
                anchor = i+1
            }
        }
        if array.isEmpty {
            return [self]
        }
        var ending_slice:Self = Self(), slice_index:Int = 0
        for i in anchor..<scalarCount {
            ending_slice[slice_index] = self[i]
            slice_index += 1
        }
        array.append(ending_slice)
        return array
    }
}
public extension SIMD where Scalar == UInt8 {
    /// - Complexity: O(_n_ * 2), where _n_ equals `leadingNonzeroByteCountSIMD`.
    func stringSIMD() -> String {
        let amount:Int = leadingNonzeroByteCountSIMD
        var characters:[Character] = [Character](repeating: Character(Unicode.Scalar(0)), count: amount)
        for i in 0..<amount {
            characters[i] = Character(Unicode.Scalar(self[i]))
        }
        return String(characters)
    }
}

// MARK: string() O(1)
extension SIMD2 where Scalar == UInt8 {
    /// - Complexity: O(1)
    @inlinable
    func chars() -> [Scalar] {
        return x == 0 ? [] : y == 0 ? [x] : [x, y]
    }
    /// Creates a `String` based on this vector's values.
    /// - Complexity: O(1)
    @inlinable
    public func string() -> String {
        return String(decoding: chars(), as: UTF8.self)
    }
}
extension SIMD4 where Scalar == UInt8 {
    /// - Complexity: O(1)
    @inlinable
    func chars() -> [Scalar] {
        if (self .!= .zero) == .init(repeating: true) {
            return [x, y, z, w]
        }
        if (lowHalf .!= .zero) != .init(repeating: true) {
            return lowHalf.chars()
        }
        return [x, y] + highHalf.chars()
    }
    /// Creates a `String` based on this vector's values.
    /// - Complexity: O(1)
    @inlinable
    public func string() -> String {
        return String(decoding: chars(), as: UTF8.self)
    }
}
extension SIMD8 where Scalar == UInt8 {
    /// - Complexity: O(1)
    @inlinable
    func chars() -> [Scalar] {
        if (lowHalf .!= .zero) != .init(repeating: true) {
            return lowHalf.chars()
        }
        return lowHalf.chars() + highHalf.chars()
    }
    /// Creates a `String` based on this vector's values.
    /// - Complexity: O(1)
    @inlinable
    public func string() -> String {
        return String(decoding: chars(), as: UTF8.self)
    }
}
extension SIMD16 where Scalar == UInt8 {
    /// - Complexity: O(1)
    @inlinable
    func chars() -> [Scalar] {
        if (lowHalf .!= .zero) != .init(repeating: true) {
            return lowHalf.chars()
        }
        return lowHalf.chars() + highHalf.chars()
    }
    /// Creates a `String` based on this vector's values.
    /// - Complexity: O(1)
    @inlinable
    public func string() -> String {
        return String(decoding: chars(), as: UTF8.self)
    }
}
extension SIMD32 where Scalar == UInt8 {
    /// - Complexity: O(1)
    @inlinable
    func chars() -> [Scalar] {
        if (lowHalf .!= .zero) != .init(repeating: true) {
            return lowHalf.chars()
        }
        return lowHalf.chars() + highHalf.chars()
    }
    /// Creates a `String` based on this vector's values.
    /// - Complexity: O(1)
    @inlinable
    public func string() -> String {
        return String(decoding: chars(), as: UTF8.self)
    }
}
extension SIMD64 where Scalar == UInt8 {
    /// - Complexity: O(1)
    @inlinable
    func chars() -> [Scalar] {
        if (lowHalf .!= .zero) != .init(repeating: true) {
            return lowHalf.chars()
        }
        return lowHalf.chars() + highHalf.chars()
    }
    /// Creates a `String` based on this vector's values.
    /// - Complexity: O(1)
    @inlinable
    public func string() -> String {
        return String(decoding: chars(), as: UTF8.self)
    }
}

// MARK: split O(1)
public extension SIMD2 where Scalar : BinaryInteger {
    /// - Complexity: O(1)
    func split(separator: Scalar) -> Self {
        if x == separator {
            return y != separator ? Self(x: y, y: 0) : self
        } else if y == separator {
            return Self(x: x, y: 0)
        }
        return self
    }
}
public extension SIMD4 where Scalar : BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    func split(separator: Scalar) -> [Self] {
        // return self if it doesn't require splitting
        guard (self .!= .init(repeating: separator)) != .init(repeating: true) else { return [self] }
        var array:[Self] = []
        array.reserveCapacity(2)
        array.append(.init())
        let separator_simd:SIMD2<Scalar> = .init(repeating: separator)
        let all_nonseparator:SIMDMask<SIMD2<Scalar>.MaskStorage> = .init(repeating: true)
        var did_split:Bool = false
        if (lowHalf .!= separator_simd) != all_nonseparator { // whether lowHalf contains separator
            array[0].lowHalf = lowHalf.split(separator: separator)
            did_split = true
        } else {
            array[0].lowHalf = lowHalf
        }
        if (highHalf .!= separator_simd) != all_nonseparator { // whether highHalf contains separator
            let value:SIMD2<Scalar> = highHalf.split(separator: separator)
            if did_split {
                array.append(.init(lowHalf: value, highHalf: .init()))
            } else if highHalf[1] == separator {
                array[0].highHalf[0] = highHalf[0]
            } else {
                array.append(.init(lowHalf: value, highHalf: .init()))
            }
        } else if did_split && lowHalf[0] == separator {
            array[0].lowHalf[1] = highHalf[0]
            array[0].highHalf[0] = highHalf[1]
        } else {
            array.append(.init(lowHalf: highHalf, highHalf: .init()))
        }
        return array
    }
}
/*
public extension SIMD8 where Scalar : BinaryInteger {
    /// - Complexity: O(1)?
    @inlinable
    func split(separator: Scalar) -> [Self] {
        let separator_simd:SIMD4<Scalar> = SIMD4<Scalar>(repeating: separator)
        let all_nonseparator:SIMDMask<SIMD4<Scalar>.MaskStorage> = .init(repeating: true)
        var array:[Self] = []
        array.reserveCapacity(2)
        var keep_lowhalf:Bool = false
        if (lowHalf .!= separator_simd) != all_nonseparator {
            for value in lowHalf.split(separator: separator) {
                array.append(Self(lowHalf: value, highHalf: .init()))
            }
        } else {
            keep_lowhalf = true
        }
        if (highHalf .!= separator_simd) != all_nonseparator {
            let values:[SIMD4<Scalar>] = highHalf.split(separator: separator)
            if keep_lowhalf {
                if highHalf[0] == separator {
                    return [
                        Self(lowHalf: lowHalf, highHalf: .init()),
                        Self(lowHalf: value, highHalf: .init())
                    ]
                } else {
                    return [Self(lowHalf: lowHalf, highHalf: .init(highHalf.x, 0))]
                }
            } else {
                for value in values {
                    array.append(Self(lowHalf: value, highHalf: .init()))
                }
            }
        } else if !keep_lowhalf {
            array.append(Self(lowHalf: highHalf, highHalf: .init()))
        }
        return array.isEmpty ? [self] : array
    }
}*/

// MARK: leadingNonByteCount O(1)
// implementation should never change
public extension SIMD2 where Scalar : BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    func leadingNonByteCount(byte: Scalar) -> Int {
        if x == byte { return 0 }
        if y == byte { return 1 }
        return scalarCount
    }
}
public extension SIMD4 where Scalar : BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    func leadingNonByteCount(byte: Scalar) -> Int {
        let byte_simd:SIMD2<Scalar> = .init(repeating: byte)
        let all_nonbyte:SIMDMask<SIMD2<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (lowHalf  .!= byte_simd) != all_nonbyte { return lowHalf.leadingNonzeroByteCount }
        if (highHalf .!= byte_simd) != all_nonbyte { return 2 + highHalf.leadingNonzeroByteCount }
        return scalarCount
    }
}
public extension SIMD8 where Scalar : BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    func leadingNonByteCount(byte: Scalar) -> Int {
        let byte_simd:SIMD4<Scalar> = .init(repeating: byte)
        let all_nonbyte:SIMDMask<SIMD4<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (lowHalf  .!= byte_simd) != all_nonbyte { return lowHalf.leadingNonzeroByteCount }
        if (highHalf .!= byte_simd) != all_nonbyte { return 4 + highHalf.leadingNonzeroByteCount }
        return scalarCount
    }
}
public extension SIMD16 where Scalar : BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    func leadingNonByteCount(byte: Scalar) -> Int {
        let byte_simd:SIMD8<Scalar> = .init(repeating: byte)
        let all_nonbyte:SIMDMask<SIMD8<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (lowHalf  .!= byte_simd) != all_nonbyte { return lowHalf.leadingNonzeroByteCount }
        if (highHalf .!= byte_simd) != all_nonbyte { return 8 + highHalf.leadingNonzeroByteCount }
        return scalarCount
    }
}
public extension SIMD32 where Scalar : BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    func leadingNonByteCount(byte: Scalar) -> Int {
        let byte_simd:SIMD16<Scalar> = .init(repeating: byte)
        let all_nonbyte:SIMDMask<SIMD16<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (lowHalf  .!= byte_simd) != all_nonbyte { return lowHalf.leadingNonzeroByteCount }
        if (highHalf .!= byte_simd) != all_nonbyte { return 16 + highHalf.leadingNonzeroByteCount }
        return scalarCount
    }
}
public extension SIMD64 where Scalar : BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    func leadingNonByteCount(byte: Scalar) -> Int {
        let byte_simd:SIMD32<Scalar> = .init(repeating: byte)
        let all_nonbyte:SIMDMask<SIMD32<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (lowHalf  .!= byte_simd) != all_nonbyte { return lowHalf.leadingNonzeroByteCount }
        if (highHalf .!= byte_simd) != all_nonbyte { return 32 + highHalf.leadingNonzeroByteCount }
        return scalarCount
    }
}

// MARK: leadingNonzeroByteCount O(1)
// implementation should never change
public extension SIMD2 where Scalar : BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    var leadingNonzeroByteCount : Int {
        if x == 0 { return 0 }
        if y == 0 { return 1 }
        return scalarCount
    }
}
public extension SIMD4 where Scalar : BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    var leadingNonzeroByteCount : Int {
        let all_nonzero:SIMDMask<SIMD2<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (lowHalf  .!= .zero) != all_nonzero { return lowHalf.leadingNonzeroByteCount }
        if (highHalf .!= .zero) != all_nonzero { return 2 + highHalf.leadingNonzeroByteCount }
        return scalarCount
    }
}
public extension SIMD8 where Scalar : BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    var leadingNonzeroByteCount : Int {
        let all_nonzero:SIMDMask<SIMD4<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (lowHalf  .!= .zero) != all_nonzero { return lowHalf.leadingNonzeroByteCount }
        if (highHalf .!= .zero) != all_nonzero { return 4 + highHalf.leadingNonzeroByteCount }
        return scalarCount
    }
}
public extension SIMD16 where Scalar : BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    var leadingNonzeroByteCount : Int {
        let all_nonzero:SIMDMask<SIMD8<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (lowHalf  .!= .zero) != all_nonzero { return lowHalf.leadingNonzeroByteCount }
        if (highHalf .!= .zero) != all_nonzero { return 8 + highHalf.leadingNonzeroByteCount }
        return scalarCount
    }
}
public extension SIMD32 where Scalar : BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    var leadingNonzeroByteCount : Int {
        let all_nonzero:SIMDMask<SIMD16<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (lowHalf  .!= .zero) != all_nonzero { return lowHalf.leadingNonzeroByteCount }
        if (highHalf .!= .zero) != all_nonzero { return 16 + highHalf.leadingNonzeroByteCount }
        return scalarCount
    }
}
public extension SIMD64 where Scalar : BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    var leadingNonzeroByteCount : Int {
        let all_nonzero:SIMDMask<SIMD32<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (lowHalf  .!= .zero) != all_nonzero { return lowHalf.leadingNonzeroByteCount }
        if (highHalf .!= .zero) != all_nonzero { return 32 + highHalf.leadingNonzeroByteCount }
        return scalarCount
    }
}

// MARK: hasPrefix O(1)
// implementation should never change
public extension SIMD4 where Scalar : BinaryInteger {
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    @inlinable func hasPrefix(_ simd: SIMD2<Scalar>) -> Bool { simd == lowHalf }
}
public extension SIMD8 where Scalar : BinaryInteger {
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    @inlinable func hasPrefix(_ simd: SIMD2<Scalar>) -> Bool { simd == lowHalf.lowHalf }
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    @inlinable func hasPrefix(_ simd: SIMD4<Scalar>) -> Bool { simd == lowHalf }
}
public extension SIMD16 where Scalar : BinaryInteger {
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    @inlinable func hasPrefix(_ simd: SIMD2<Scalar>) -> Bool { simd == lowHalf.lowHalf.lowHalf }
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    @inlinable func hasPrefix(_ simd: SIMD4<Scalar>) -> Bool { simd == lowHalf.lowHalf }
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    @inlinable func hasPrefix(_ simd: SIMD8<Scalar>) -> Bool { simd == lowHalf }
}
public extension SIMD32 where Scalar : BinaryInteger {
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    @inlinable func hasPrefix(_ simd: SIMD2<Scalar>) -> Bool { simd == lowHalf.lowHalf.lowHalf.lowHalf }
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    @inlinable func hasPrefix(_ simd: SIMD4<Scalar>) -> Bool { simd == lowHalf.lowHalf.lowHalf }
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    @inlinable func hasPrefix(_ simd: SIMD8<Scalar>) -> Bool { simd == lowHalf.lowHalf }
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    @inlinable func hasPrefix(_ simd: SIMD16<Scalar>) -> Bool { simd == lowHalf }
}
public extension SIMD64 where Scalar : BinaryInteger {
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    @inlinable func hasPrefix(_ simd: SIMD2<Scalar>) -> Bool { simd == lowHalf.lowHalf.lowHalf.lowHalf.lowHalf }
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    @inlinable func hasPrefix(_ simd: SIMD4<Scalar>) -> Bool { simd == lowHalf.lowHalf.lowHalf.lowHalf }
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    @inlinable func hasPrefix(_ simd: SIMD8<Scalar>) -> Bool { simd == lowHalf.lowHalf.lowHalf }
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    @inlinable func hasPrefix(_ simd: SIMD16<Scalar>) -> Bool { simd == lowHalf.lowHalf }
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    @inlinable func hasPrefix(_ simd: SIMD32<Scalar>) -> Bool { simd == lowHalf }
}

/*
// MARK: hasSuffix O(1)
public extension SIMD2 where Scalar : BinaryInteger {
    @inlinable func hasSuffix(_ simd: SIMD2<Scalar>) -> Bool {
    }
}*/
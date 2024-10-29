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
        guard (self .!= .init(repeating: separator)) != .init(repeating: true) else { return [self] }
        let half:SIMD2<Scalar> = .init(repeating: separator)
        let half_all_nonseparator:SIMDMask<SIMD2<Scalar>.MaskStorage> = .init(repeating: true)
        var array:[Self] = Array(repeating: .init(), count: 1)
        var did_split:Bool = false
        if (lowHalf .!= half) != half_all_nonseparator {
            array[0].lowHalf = lowHalf.split(separator: separator)
            did_split = true
        } else {
            array[0].lowHalf = lowHalf
        }
        if (highHalf .!= half) != half_all_nonseparator {
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
        if (lowHalf .!= .zero) != all_nonzero  { return lowHalf.leadingNonzeroByteCount }
        if (highHalf .!= .zero) != all_nonzero { return 2 + highHalf.leadingNonzeroByteCount }
        return scalarCount
    }
}
public extension SIMD8 where Scalar : BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    var leadingNonzeroByteCount : Int {
        let all_nonzero:SIMDMask<SIMD4<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (lowHalf .!= .zero) != all_nonzero  { return lowHalf.leadingNonzeroByteCount }
        if (highHalf .!= .zero) != all_nonzero { return 4 + highHalf.leadingNonzeroByteCount }
        return scalarCount
    }
}
public extension SIMD16 where Scalar : BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    var leadingNonzeroByteCount : Int {
        let all_nonzero:SIMDMask<SIMD8<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (lowHalf .!= .zero) != all_nonzero  { return lowHalf.leadingNonzeroByteCount }
        if (highHalf .!= .zero) != all_nonzero { return 8 + highHalf.leadingNonzeroByteCount }
        return scalarCount
    }
}
public extension SIMD32 where Scalar : BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    var leadingNonzeroByteCount : Int {
        let all_nonzero:SIMDMask<SIMD16<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (lowHalf .!= .zero) != all_nonzero  { return lowHalf.leadingNonzeroByteCount }
        if (highHalf .!= .zero) != all_nonzero { return 16 + highHalf.leadingNonzeroByteCount }
        return scalarCount
    }
}
public extension SIMD64 where Scalar : BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    var leadingNonzeroByteCount : Int {
        let all_nonzero:SIMDMask<SIMD32<Scalar.SIMDMaskScalar>> = .init(repeating: true)
        if (lowHalf .!= .zero) != all_nonzero  { return lowHalf.leadingNonzeroByteCount }
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
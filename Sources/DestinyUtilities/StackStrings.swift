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
    init(_ string: inout String) {
        var item:Self = Self()
        string.withUTF8 { p in
            for i in 0..<Swift.min(p.count, Self.scalarCount) {
                item[i] = Scalar(p[i])
            }
        }
        self = item
    }

    /// - Complexity: O(_n_) where _n_ equals `scalarCount`.
    var leadingNonzeroByteCount : Int { // TODO: make SIMD fast
        for i in 0..<scalarCount {
            if self[i] == 0 {
                return i
            }
        }
        return 0
    }

    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(_n_) where _n_ equals the target SIMD's `scalarCount`.
    func hasPrefixSIMD<T: SIMD>(_ simd: T) -> Bool where T.Scalar: BinaryInteger, Scalar == T.Scalar {
        var nibble:T = T()
        for i in 0..<T.scalarCount {
            nibble[i] = self[i]
        }
        return nibble == simd
    }

    func split(separator: Scalar) -> [Self] { // TODO: make SIMD fast
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

// MARK: hasPrefix O(1)
public extension SIMD4<UInt8> {
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    func hasPrefix(_ simd: SIMD2<UInt8>) -> Bool {
        return simd == SIMD2<UInt8>(self[0], self[1])
    }
}
public extension SIMD8<UInt8> {
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    func hasPrefix(_ simd: SIMD2<UInt8>) -> Bool {
        return simd == SIMD2<UInt8>(self[0], self[1])
    }
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    func hasPrefix(_ simd: SIMD4<UInt8>) -> Bool {
        return simd == SIMD4<UInt8>(self[0], self[1], self[2], self[3])
    }
}
public extension SIMD16<UInt8> {
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    func hasPrefix(_ simd: SIMD2<UInt8>) -> Bool {
        return simd == SIMD2<UInt8>(self[0], self[1])
    }
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    func hasPrefix(_ simd: SIMD4<UInt8>) -> Bool {
        return simd == SIMD4<UInt8>(self[0], self[1], self[2], self[3])
    }
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    func hasPrefix(_ simd: SIMD8<UInt8>) -> Bool {
        return simd == SIMD8<UInt8>(self[0], self[1], self[2], self[3], self[4], self[5], self[6], self[7])
    }
}
public extension SIMD32<UInt8> {
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    func hasPrefix(_ simd: SIMD2<UInt8>) -> Bool {
        return simd == SIMD2<UInt8>(self[0], self[1])
    }
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    func hasPrefix(_ simd: SIMD4<UInt8>) -> Bool {
        return simd == SIMD4<UInt8>(self[0], self[1], self[2], self[3])
    }
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    func hasPrefix(_ simd: SIMD8<UInt8>) -> Bool {
        return simd == SIMD8<UInt8>(self[0], self[1], self[2], self[3], self[4], self[5], self[6], self[7])
    }
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    func hasPrefix(_ simd: SIMD16<UInt8>) -> Bool {
        return simd == SIMD16<UInt8>(self[0], self[1], self[2], self[3], self[4], self[5], self[6], self[7], self[8], self[9], self[10], self[11], self[12], self[13], self[14], self[15])
    }
}
public extension SIMD64<UInt8> {
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    func hasPrefix(_ simd: SIMD2<UInt8>) -> Bool {
        return simd == SIMD2<UInt8>(self[0], self[1])
    }
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    func hasPrefix(_ simd: SIMD4<UInt8>) -> Bool {
        return simd == SIMD4<UInt8>(self[0], self[1], self[2], self[3])
    }
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    func hasPrefix(_ simd: SIMD8<UInt8>) -> Bool {
        return simd == SIMD8<UInt8>(self[0], self[1], self[2], self[3], self[4], self[5], self[6], self[7])
    }
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    func hasPrefix(_ simd: SIMD16<UInt8>) -> Bool {
        return simd == SIMD16<UInt8>(self[0], self[1], self[2], self[3], self[4], self[5], self[6], self[7], self[8], self[9], self[10], self[11], self[12], self[13], self[14], self[15])
    }
    /// Whether or not this SIMD is prefixed with certain integers.
    /// - Complexity: O(1)
    func hasPrefix(_ simd: SIMD32<UInt8>) -> Bool {
        return simd == SIMD32<UInt8>(self[0], self[1], self[2], self[3], self[4], self[5], self[6], self[7], self[8], self[9], self[10], self[11], self[12], self[13], self[14], self[15], self[16], self[17], self[18], self[19], self[20], self[21], self[22], self[23], self[24], self[25], self[26], self[27], self[28], self[29], self[30], self[31])
    }
}
//
//  SIMDExtensions+Split.swift
//
//
//  Created by Evan Anderson on 10/22/24.
//

// MARK: SIMD2
extension SIMD2 where Scalar : BinaryInteger {
    /// - Complexity: O(1)
    public func split(separator: Scalar) -> Self {
        if x == separator {
            return y != separator ? Self(x: y, y: 0) : self
        } else if y == separator {
            return Self(x: x, y: 0)
        }
        return self
    }
}

// MARK: SIMD4
extension SIMD4 where Scalar : BinaryInteger {
    /// - Complexity: O(1)
    @inlinable
    public func split(separator: Scalar) -> [Self] {
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
// MARK: SIMD8
extension SIMD8 where Scalar : BinaryInteger {
    /// - Complexity: O(1)?
    @inlinable
    public func split(separator: Scalar) -> [Self] {
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
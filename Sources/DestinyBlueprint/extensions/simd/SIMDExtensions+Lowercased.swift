//
//  SIMDExtensions+Lowercased.swift
//
//
//  Created by Evan Anderson on 4/17/25.
//

extension SIMD where Scalar: FixedWidthInteger {
    /// - Complexity: O(1)
    @inlinable
    public func lowercased() -> Self {
        var upperCase = self .>= 65
        upperCase .&= self .<= 90

        var addition = Self.zero
        addition.replace(with: 32, where: upperCase) // TODO: use a SIMD blend operation (no existing standard Swift operation)
        return self &+ addition
    }
}
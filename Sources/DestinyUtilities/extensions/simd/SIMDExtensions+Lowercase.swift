//
//  SIMDExtensions+Lowercase.swift
//
//
//  Created by Evan Anderson on 4/17/25.
//

extension SIMD where Scalar: FixedWidthInteger {
    @inlinable
    public func lowercase() -> Self {
        var upperCase = self .>= 65
        upperCase .&= self .<= 90

        var addition:Self = .zero
        addition.replace(with: 32, where: upperCase)
        return self &+ addition
    }
}
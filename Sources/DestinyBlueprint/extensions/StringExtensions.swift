//
//  StringExtensions.swift
//
//
//  Created by Evan Anderson on 4/19/25.
//

extension String {
    @inlinable
    public mutating func append<let count: Int>(_ array: InlineArray<count, UInt8>) {
        for i in array.indices {
            let char = array[i]
            if char == 0 {
                break
            }
            self.append(Character(Unicode.Scalar(char)))
        }
    }
}
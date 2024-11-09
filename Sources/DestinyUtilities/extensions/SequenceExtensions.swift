//
//  SequenceExtensions.swift
//
//
//  Created by Evan Anderson on 11/7/24.
//

// MARK: Array
package extension Array {
    func get(_ index: Int) -> Element? {
        return index < count ? self[index] : nil
    }
}
public extension Array where Element == SIMD64<UInt8> {
    // TODO: finish
}
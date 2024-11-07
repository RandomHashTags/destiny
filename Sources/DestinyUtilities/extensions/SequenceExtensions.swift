//
//  SequenceExtensions.swift
//
//
//  Created by Evan Anderson on 11/7/24.
//

// MARK: Array
extension Array {
    func get(_ index: Int) -> Element? {
        return index < count ? self[index] : nil
    }
}
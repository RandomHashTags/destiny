
#if canImport(Foundation)
import Foundation
#endif

// MARK: init
extension InlineArrayProtocol {
    /// - Complexity: O(_n_) where _n_ is the length of the collection.
    @inlinable
    public init<T: Collection<Element>>(_ array: T) {
        self = .init(repeating: array[array.startIndex])
        for i in self.indices {
            self.setItemAt(index: i, element: array[array.index(array.startIndex, offsetBy: i)])
        }
    }
}
extension InlineArrayProtocol where Element == UInt8 {
    /// - Complexity: O(_n_) where _n_ is the length of the collection.
    @inlinable
    public init(_ utf8: String.UTF8View) {
        self = .init(repeating: 0)
        for i in self.indices {
            self.setItemAt(index: i, element: utf8[utf8.index(utf8.startIndex, offsetBy: i)])
        }
    }

    /// - Complexity: O(_n_) where _n_ is the length of the collection.
    @inlinable
    public init<T: SIMD>(_ simd: T) where T.Scalar == Element {
        self = .init(repeating: 0)
        for i in simd.indices {
            self.setItemAt(index: i, element: simd[i])
        }
    }
}

// MARK: split
extension InlineArrayProtocol where Element: Equatable {
    /// - Complexity: O(_n_) where _n_ is the length of the collection.
    @inlinable
    public func split<let sliceLength: Int>(
        separator: Element,
        defaultValue: Element,
        yield: (InlineArray<sliceLength, Element>) -> Void
    ) -> InlineArray<sliceLength, Element>? {
        var beginning = startIndex
        for i in self.indices {
            let element = self.itemAt(index: i)
            if element == separator {
                var slice = InlineArray<sliceLength, Element>(repeating: defaultValue)
                var sliceIndex = 0
                while beginning < i, sliceIndex < sliceLength {
                    slice[sliceIndex] = self.itemAt(index: beginning)
                    beginning += 1
                    sliceIndex += 1
                }
                yield(slice)
            }
        }
        return nil
    }
    @discardableResult
    @inlinable
    public func split<let sliceLength: Int>(
        separators: Element...,
        defaultValue: Element,
        offset: Index = 0,
        yield: (InlineArray<sliceLength, Element>) throws -> Void
    ) rethrows -> InlineArray<sliceLength, Element>? {
        var beginning = offset
        var i = offset
        loop: while i < count {
            let startIndex = i
            var element = self.itemAt(index: i)
            for separator in separators {
                i += 1
                if element != separator {
                    continue loop
                } else {
                    element = self.itemAt(index: i)
                }
            }
            var slice = InlineArray<sliceLength, Element>(repeating: defaultValue)
            var sliceIndex = 0
            while beginning < startIndex, sliceIndex < sliceLength {
                slice[sliceIndex] = self.itemAt(index: beginning)
                beginning += 1
                sliceIndex += 1
            }
            beginning += separators.count
            try yield(slice)
            i += 1
        }
        return nil
    }
}

// MARK: Split InlineVLArray
extension InlineArrayProtocol where Element == UInt8 {
    /// - Parameters:
    ///   - yield: Yields a slice of the result; returns whether or not to continue splitting.
    /// - Complexity: O(1)
    @inlinable
    public func split(
        separator: Element,
        defaultValue: Element,
        offset: Index = 0,
        yield: (inout InlineVLArray<Element>) throws -> Bool
    ) rethrows {
        let separatorSIMD = SIMD64<UInt8>(repeating: separator)
        let noSeparatorFoundMask = SIMDMask<SIMD64<UInt8>.MaskStorage>.init(repeating: false)
        var beginning = startIndex + offset
        var index = offset
        while index < endIndex {
            let remaining = index.distance(to: endIndex)
            if remaining >= 64 {
                try splitSIMD64(
                    separator: separator,
                    separatorSIMD: separatorSIMD,
                    noSeparatorFoundMask: noSeparatorFoundMask,
                    beginning: &beginning,
                    index: &index,
                    yield: yield
                )
            } else if remaining >= 32 {
                try splitSIMD32(
                    separator: separator,
                    separatorSIMD: separatorSIMD,
                    noSeparatorFoundMask: noSeparatorFoundMask,
                    beginning: &beginning,
                    index: &index,
                    yield: yield
                )
            } else if remaining >= 16 {
                try splitSIMD16(
                    separator: separator,
                    separatorSIMD: separatorSIMD,
                    noSeparatorFoundMask: noSeparatorFoundMask,
                    beginning: &beginning,
                    index: &index,
                    yield: yield
                )
            } else if remaining >= 8 {
                try splitSIMD8(
                    separator: separator,
                    separatorSIMD: separatorSIMD,
                    noSeparatorFoundMask: noSeparatorFoundMask,
                    beginning: &beginning,
                    index: &index,
                    yield: yield
                )
            } else if remaining >= 4 {
                try splitSIMD4(
                    separator: separator,
                    separatorSIMD: separatorSIMD,
                    noSeparatorFoundMask: noSeparatorFoundMask,
                    beginning: &beginning,
                    index: &index,
                    yield: yield
                )
            } else {
                while index < endIndex {
                    if self.itemAt(index: index) == separator {
                        let continueYielding = try yieldInlineVLArray(capacity: beginning.distance(to: index), beginning: &beginning, index: &index, defaultValue: 0, yield: yield)
                        if !continueYielding {
                            break
                        }
                    }
                    index += 1
                }
            }
        }
    }
    @inlinable
    func splitSIMD64(
        separator: Element,
        separatorSIMD: SIMD64<UInt8>,
        noSeparatorFoundMask: SIMDMask<SIMD64<UInt8>.MaskStorage>,
        beginning: inout Index,
        index: inout Index,
        yield: (inout InlineVLArray<Element>) throws -> Bool
    ) rethrows {
        let buffer = simd64(startIndex: index)
        if (buffer .== separatorSIMD) == noSeparatorFoundMask {
            index += 64
        } else {
            try splitSIMD32(separator: separator, separatorSIMD: separatorSIMD, noSeparatorFoundMask: noSeparatorFoundMask, beginning: &beginning, index: &index, yield: yield)
        }
    }
    @inlinable
    func splitSIMD32(
        separator: Element,
        separatorSIMD: SIMD64<UInt8>,
        noSeparatorFoundMask: SIMDMask<SIMD64<UInt8>.MaskStorage>,
        beginning: inout Index,
        index: inout Index,
        yield: (inout InlineVLArray<Element>) throws -> Bool
    ) rethrows {
        let mask:SIMDMask<SIMD32<UInt8>.MaskStorage> = withUnsafeBytes(of: noSeparatorFoundMask, { $0.baseAddress!.bindMemory(to: SIMDMask<SIMD32<UInt8>.MaskStorage>.self, capacity: 32).pointee })
        let buffer = simd32(startIndex: index)
        if (buffer .== separatorSIMD.lowHalf) == mask {
            index += 32
        } else {
            try splitSIMD16(separator: separator, separatorSIMD: separatorSIMD, noSeparatorFoundMask: noSeparatorFoundMask, beginning: &beginning, index: &index, yield: yield)
        }
    }
    @inlinable
    func splitSIMD16(
        separator: Element,
        separatorSIMD: SIMD64<UInt8>,
        noSeparatorFoundMask: SIMDMask<SIMD64<UInt8>.MaskStorage>,
        beginning: inout Index,
        index: inout Index,
        yield: (inout InlineVLArray<Element>) throws -> Bool
    ) rethrows {
        let mask:SIMDMask<SIMD16<UInt8>.MaskStorage> = withUnsafeBytes(of: noSeparatorFoundMask, { $0.baseAddress!.bindMemory(to: SIMDMask<SIMD16<UInt8>.MaskStorage>.self, capacity: 16).pointee })
        let buffer = simd16(startIndex: index)
        if (buffer .== separatorSIMD.lowHalf.lowHalf) == mask {
            index += 16
        } else {
            try splitSIMD8(separator: separator, separatorSIMD: separatorSIMD, noSeparatorFoundMask: noSeparatorFoundMask, beginning: &beginning, index: &index, yield: yield)
        }
    }
    @inlinable
    func splitSIMD8(
        separator: Element,
        separatorSIMD: SIMD64<UInt8>,
        noSeparatorFoundMask: SIMDMask<SIMD64<UInt8>.MaskStorage>,
        beginning: inout Index,
        index: inout Index,
        yield: (inout InlineVLArray<Element>) throws -> Bool
    ) rethrows {
        let mask:SIMDMask<SIMD8<UInt8>.MaskStorage> = withUnsafeBytes(of: noSeparatorFoundMask, { $0.baseAddress!.bindMemory(to: SIMDMask<SIMD8<UInt8>.MaskStorage>.self, capacity: 8).pointee })
        let buffer = simd8(startIndex: index)
        if (buffer .== separatorSIMD.lowHalf.lowHalf.lowHalf) == mask {
            index += 8
        } else {
            try splitSIMD4(separator: separator, separatorSIMD: separatorSIMD, noSeparatorFoundMask: noSeparatorFoundMask, beginning: &beginning, index: &index, yield: yield)
        }
    }
    @inlinable
    func splitSIMD4(
        separator: Element,
        separatorSIMD: SIMD64<UInt8>,
        noSeparatorFoundMask: SIMDMask<SIMD64<UInt8>.MaskStorage>,
        beginning: inout Index,
        index: inout Index,
        yield: (inout InlineVLArray<Element>) throws -> Bool
    ) rethrows {
        let mask:SIMDMask<SIMD4<UInt8>.MaskStorage> = withUnsafeBytes(of: noSeparatorFoundMask, { $0.baseAddress!.bindMemory(to: SIMDMask<SIMD4<UInt8>.MaskStorage>.self, capacity: 4).pointee })
        let buffer = simd4(startIndex: index)
        if (buffer .== separatorSIMD.lowHalf.lowHalf.lowHalf.lowHalf) == mask {
            index += 4
        } else {
            // contains separator
            for i in buffer.indices {
                if buffer[i] == separator {
                    let continueYielding = try yieldInlineVLArray(capacity: beginning.distance(to: index), beginning: &beginning, index: &index, defaultValue: 0, yield: yield)
                    if !continueYielding {
                        break
                    }
                }
                index += 1
            }
        }
    }
    @inlinable
    func yieldInlineVLArray(
        capacity: Int,
        beginning: inout Index,
        index: inout Index,
        defaultValue: Element,
        yield: (inout InlineVLArray<Element>) throws -> Bool
    ) rethrows -> Bool {
        var continueYielding = true
        try InlineVLArray<Element>.create(amount: capacity, default: defaultValue, { array in
            var arrayIndex = 0
            var i = beginning
            while i < index {
                array.setItemAt(index: arrayIndex, element: self.itemAt(index: i))
                arrayIndex += 1
                i += 1
            }
            continueYielding = try yield(&array)
            if !continueYielding {
                index = endIndex
            } else {
                beginning = index+1
            }
        })
        return continueYielding
    }
}

// MARK: first index
extension InlineArrayProtocol where Element: Equatable {
    /// - Complexity: O(_n_) where _n_ is the length of the collection.
    @inlinable
    public func firstIndex(of element: Element, offset: Index = 0) -> Index? {
        var i = startIndex + offset
        while i < endIndex {
            if self.itemAt(index: i) == element {
                return i
            }
            i += 1
        }
        return nil
    }
}

// MARK: first slice
extension InlineArrayProtocol where Element: Equatable {
    /// - Complexity: O(_n_) where _n_ is the length of the collection.
    @inlinable
    public func firstSlice<let sliceLength: Int>(separator: Element, defaultValue: Element, offset: Index = 0) -> (slice: InlineArray<sliceLength, Element>, index: Index) {
        let index = firstIndex(of: separator, offset: offset) ?? endIndex
        let numberOfItems = min(sliceLength, offset.distance(to: index))
        var slice:InlineArray<sliceLength, Element> = .init(repeating: defaultValue)
        var targetIndex = offset
        var i = 0
        while i < numberOfItems, targetIndex < sliceLength {
            slice[i] = self.itemAt(index: targetIndex)
            targetIndex += 1
            i += 1
        }
        return (slice, index)
    }

    /// - Complexity: O(_n_) where _n_ is the length of the collection.
    @inlinable
    public func firstSlice(separator: Element, defaultValue: Element, offset: Index = 0, _ closure: (_ slice: InlineVLArray<Element>, _ index: Index) -> Void) {
        let index = firstIndex(of: separator, offset: offset) ?? endIndex
        InlineVLArray<Element>.create(amount: offset.distance(to: index), default: defaultValue) { array in
            var targetIndex = offset
            var i = 0
            while targetIndex < index {
                array.setItemAt(index: i, element: self.itemAt(index: targetIndex))
                targetIndex += 1
                i += 1
            }
            closure(array, index)
        }
    }
}

// MARK: slice
extension InlineArrayProtocol {
    /// - Complexity: O(_n_) where _n_ is the length of the collection.
    @inlinable
    public func slice<let sliceLength: Int>(startIndex: Index, endIndex: Index, defaultValue: Element) -> InlineArray<sliceLength, Element> {
        var slice = InlineArray<sliceLength, Element>(repeating: defaultValue)
        var index = 0
        var i = startIndex
        let targetEndIndex = min(endIndex, self.endIndex)
        while i < targetEndIndex, index < sliceLength {
            slice[index] = self.itemAt(index: i)
            index += 1
            i += 1
        }
        return slice
    }
}

// MARK: has prefix
extension InlineArrayProtocol where Element == UInt8 {
    /// - Complexity: O(_n_) where _n_ is the length of the collection.
    @inlinable
    public func hasPrefix<T: InlineArrayProtocol>(_ array: T) -> Bool where T.Element == Element {
        let minCount = min(count, array.count)
        // TODO: support SIMD
        /*switch minCount {
        case let x where x <= 8:
            break
        case let x where x <= 16:
            break
        case let x where x <= 32:
            break
        case let x where x <= 64:
            break
        default:
            break
        }*/
        var i = startIndex
        while i < minCount {
            if self.itemAt(index: i) != array.itemAt(index: i) {
                return false
            }
            i += 1
        }
        return true
    }
}

// MARK: string
extension InlineArrayProtocol where Element == UInt8 {
    @inlinable
    public func string(offset: Index = 0) -> String {
        var s = ""
        var i = offset
        while i < endIndex {
            let char = self.itemAt(index: i)
            if char == 0 {
                break
            }
            s.append(Character(Unicode.Scalar(char)))
            i += 1
        }
        return s
    }
}

#if canImport(Foundation)
// MARK: lowercased
extension InlineArrayProtocol where Element == UInt8 {
    /// - Complexity: O(_n_ * 2) where _n_ is the length of the collection.
    @inlinable
    public func lowercased() -> Self {
        var value = self
        let simds = Int(ceil(Double(count) / 64)) // need Foundation for `ceil` call
        var startIndex = startIndex
        for _ in 0..<simds {
            let simd = simd64(startIndex: startIndex).lowercased()
            let filled = min(64, endIndex - startIndex)
            for i in 0..<filled {
                value.setItemAt(index: startIndex + i, element: simd[i])
            }
            startIndex += 64
        }
        return value
    }
}
#endif

// MARK: SIMD
extension InlineArrayProtocol where Element: SIMDScalar {
    /// - Complexity: O(1)
    @inlinable
    public func simd4(startIndex: Index = 0) -> SIMD4<Element> {
        simd(startIndex: startIndex)
    }

    /// - Complexity: O(1)
    @inlinable
    public func simd8(startIndex: Index = 0) -> SIMD8<Element> {
        simd(startIndex: startIndex)
    }

    /// - Complexity: O(1)
    @inlinable
    public func simd16(startIndex: Index = 0) -> SIMD16<Element> {
        simd(startIndex: startIndex)
    }

    /// - Complexity: O(1)
    @inlinable
    public func simd32(startIndex: Index = 0) -> SIMD32<Element> {
        simd(startIndex: startIndex)
    }

    /// - Complexity: O(1)
    @inlinable
    public func simd64(startIndex: Index = 0) -> SIMD64<Element> {
        simd(startIndex: startIndex)
    }

    /// Binds the elements to a type conforming to `SIMD where SIMD.Scalar == Element`.
    /// 
    /// - Parameters:
    ///   - startIndex: Where the first element is located.
    /// - Complexity: O(1)
    @inlinable
    public func simd<T: SIMD>(startIndex: Index = 0) -> T where T.Scalar == Element {
        return withUnsafeBytes(of: self) { p in
            return (p.baseAddress! + startIndex).bindMemory(to: T.self, capacity: T.scalarCount).pointee
        }
    }
}

// MARK: Equatable
extension InlineArrayProtocol where Element: Equatable {
    /// - Complexity: O(_n_) where _n_ is the length of the collection.
    @inlinable
    public static func == (lhs: Self?, rhs: Self) -> Bool {
        guard let lhs else { return false }
        return lhs == rhs
    }

    /// - Complexity: O(_n_) where _n_ is the length of the collection.
    @inlinable
    public static func == (lhs: Self, rhs: Self?) -> Bool {
        guard let rhs else { return false }
        return lhs == rhs
    }

    /// - Complexity: O(_n_) where _n_ is the length of the collection.
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        for i in lhs.indices {
            if lhs.itemAt(index: i) != rhs.itemAt(index: i) {
                return false
            }
        }
        return true
    }
}

extension InlineArrayProtocol where Element == UInt8 {
    @inlinable
    public static func == <S: StringProtocol>(lhs: Self, rhs: S) -> Bool {
        let stringCount = rhs.count
        if lhs.count == rhs.count {
            for i in 0..<lhs.count {
                if lhs.itemAt(index: i) != rhs[rhs.index(rhs.startIndex, offsetBy: i)].asciiValue {
                    return false
                }
            }
            return true
        } else if lhs.count > stringCount {
            var i = 0
            while i < stringCount {
                if lhs.itemAt(index: i) != rhs[rhs.index(rhs.startIndex, offsetBy: i)].asciiValue {
                    return false
                }
                i += 1
            }
            return lhs.itemAt(index: i) == 0
        } else {
            return false
        }
    }

    @inlinable
    public func stringRepresentationsAreEqual<T: InlineArrayProtocol>(_ array: T) -> Bool where T.Element == Element {
        let minCount = min(count, array.count)
        var i = startIndex
        while i < minCount {
            if self.itemAt(index: i) != array.itemAt(index: i) {
                return false
            }
            i += 1
        }
        if count == array.count {
            return true
        }
        return count > array.count ? self.itemAt(index: i) == 0: array.itemAt(index: i) == 0
    }
}

// MARK: Pattern matching
extension InlineArrayProtocol where Element: Equatable {
    /// - Complexity: O(_n_) where _n_ is the length of the collection.
    @inlinable
    public static func ~= (lhs: Self, rhs: Self) -> Bool {
        return lhs == rhs
    }
}
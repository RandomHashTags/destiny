import Foundation

// MARK: init
extension InlineArray {
    @inlinable
    public init<T: Collection<Element>>(_ array: T) {
        self = .init(repeating: array[array.startIndex])
        for i in self.indices {
            self[i] = array[array.index(array.startIndex, offsetBy: i)]
        }
    }
}
extension InlineArray where Element == UInt8 {
    @inlinable
    public init(_ utf8: String.UTF8View) {
        self = .init(repeating: 0)
        for i in self.indices {
            self[i] = utf8[utf8.index(utf8.startIndex, offsetBy: i)]
        }
    }
}

// MARK: split
extension InlineArray where Element: Equatable {
    @discardableResult
    @inlinable
    public func split<let sliceLength: Int>(
        separator: Element,
        defaultValue: Element,
        yield: (InlineArray<sliceLength, Element>) -> Void
    ) -> InlineArray<sliceLength, Element>? {
        var beginning = startIndex
        for i in self.indices {
            let element = self[i]
            if element == separator {
                var slice:InlineArray<sliceLength, Element> = .init(repeating: defaultValue)
                var sliceIndex = 0
                while beginning < i, sliceIndex < sliceLength {
                    slice[sliceIndex] = self[beginning]
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
            var element = self[i]
            for separator in separators {
                if element != separator {
                    i += 1
                    continue loop
                } else {
                    i += 1
                    element = self[i]
                }
            }
            var slice:InlineArray<sliceLength, Element> = .init(repeating: defaultValue)
            var sliceIndex = 0
            while beginning < startIndex, sliceIndex < sliceLength {
                slice[sliceIndex] = self[beginning]
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

// MARK: first index
extension InlineArray where Element: Equatable {
    @inlinable
    public func firstIndex(of element: Element, offset: Index = 0) -> Index? {
        var i = startIndex + offset
        while i < endIndex {
            if self[i] == element {
                return i
            }
            i += 1
        }
        return nil
    }
}

// MARK: first slice
extension InlineArray where Element: Equatable {
    @inlinable
    public func firstSlice<let sliceLength: Int>(separator: Element, defaultValue: Element, offset: Index = 0) -> (slice: InlineArray<sliceLength, Element>, index: Index) {
        let index = firstIndex(of: separator, offset: offset) ?? endIndex
        var slice:InlineArray<sliceLength, Element> = .init(repeating: defaultValue)
        var targetIndex = offset
        for i in 0..<min(sliceLength, offset.distance(to: index)) {
            slice[i] = self[targetIndex]
            targetIndex += 1
        }
        return (slice, index)
    }
}

// MARK: slice
extension InlineArray {
    @inlinable
    public func slice<let sliceLength: Int>(startIndex: Index, endIndex: Index, defaultValue: Element) -> InlineArray<sliceLength, Element> {
        var slice:InlineArray<sliceLength, Element> = .init(repeating: defaultValue)
        var index = 0
        for i in startIndex..<endIndex {
            slice[index] = self[i]
            index += 1
        }
        return slice
    }
}

// MARK: string
extension InlineArray where Element == UInt8 {
    @inlinable
    public func string() -> String {
        var s = ""
        for i in self.indices {
            let char = self[i]
            if char == 0 {
                break
            }
            s.append(Character(Unicode.Scalar(char)))
        }
        return s
    }
}

// MARK: lowercase
extension InlineArray where Element == UInt8 {
    @inlinable
    public func lowercase() -> Self {
        var value = self
        let simds = Int(ceil(Double(count) / 64))
        var startIndex = startIndex
        for _ in 0..<simds {
            let simd = simd64(startIndex: startIndex).lowercase()
            for i in 0..<64 {
                value[startIndex + i] = simd[i]
            }
            startIndex += 64
        }
        return value
    }
}

// MARK: SIMD
extension InlineArray where Element: SIMDScalar {
    @inlinable
    public func simd8(startIndex: Index = 0) -> SIMD16<Element> {
        return simd(startIndex: startIndex)
    }
    @inlinable
    public func simd16(startIndex: Index = 0) -> SIMD16<Element> {
        return simd(startIndex: startIndex)
    }
    @inlinable
    public func simd32(startIndex: Index = 0) -> SIMD32<Element> {
        return simd(startIndex: startIndex)
    }
    @inlinable
    public func simd64(startIndex: Index = 0) -> SIMD64<Element> {
        return simd(startIndex: startIndex)
    }

    @inlinable
    public func simd<T: SIMD>(startIndex: Index = 0) -> T where T.Scalar == Element {
        var simd = T()
        var i = 0
        var index = startIndex
        let endIndex = min(endIndex, startIndex + T.scalarCount)
        while index < endIndex {
            simd[i] = self[index]
            index += 1
            i += 1
        }
        return simd
    }
}

// MARK: Equatable
extension InlineArray where Element: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.count == rhs.count else { return false }
        for i in 0..<lhs.count {
            if lhs[i] != rhs[i] {
                return false
            }
        }
        return true
    }
}

// MARK: Pattern matching
extension InlineArray where Element: Equatable {
    @inlinable
    public static func ~= (lhs: Self, rhs: Self) -> Bool {
        return lhs == rhs
    }
}
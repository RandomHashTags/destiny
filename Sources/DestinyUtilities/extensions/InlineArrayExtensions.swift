
#if compiler(>=6.2)

// MARK: init
extension InlineArray {
    package init<T: Collection<Element>>(_ array: T) {
        self = .init(repeating: array[array.startIndex])
        for i in self.indices {
            self[i] = array[array.index(array.startIndex, offsetBy: i)]
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
        yield: (InlineArray<sliceLength, Element>) throws -> Void
    ) rethrows -> InlineArray<sliceLength, Element>? {
        var beginning = startIndex
        var i = 0
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
        s.reserveCapacity(self.count)
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

#endif
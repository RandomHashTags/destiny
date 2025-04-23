
#if canImport(Foundation)
import Foundation
#endif

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

    @inlinable
    public init<T: SIMD>(_ simd: T) where T.Scalar == Element {
        self = .init(repeating: 0)
        for i in simd.indices {
            self[i] = simd[i]
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
        let numberOfItems = min(sliceLength, offset.distance(to: index))
        var slice:InlineArray<sliceLength, Element> = .init(repeating: defaultValue)
        var targetIndex = offset
        var i = 0
        while i < numberOfItems, targetIndex < sliceLength {
            slice[i] = self[targetIndex]
            targetIndex += 1
            i += 1
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
        var i = startIndex
        let targetEndIndex = min(endIndex, self.endIndex)
        while i < targetEndIndex, index < sliceLength {
            slice[index] = self[i]
            index += 1
            i += 1
        }
        return slice
    }
}

// MARK: has prefix
extension InlineArray where Element == UInt8 {
    @inlinable
    public func hasPrefix<let secondCount: Int>(_ array: InlineArray<secondCount, Element>) -> Bool {
        let minCount = min(count, secondCount)
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
            if self[i] != array[i] {
                return false
            }
            i += 1
        }
        return true
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

#if canImport(Foundation)
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
#endif

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
    public static func == (lhs: Self?, rhs: Self) -> Bool {
        guard let lhs else { return false }
        return lhs == rhs
    }
    @inlinable
    public static func == (lhs: Self, rhs: Self?) -> Bool {
        guard let rhs else { return false }
        return lhs == rhs
    }

    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        for i in lhs.indices {
            if lhs[i] != rhs[i] {
                return false
            }
        }
        return true
    }
}

extension InlineArray where Element == UInt8 {
    @inlinable
    public static func == <S: StringProtocol>(lhs: Self, rhs: S) -> Bool {
        let stringCount = rhs.count
        if lhs.count == rhs.count {
            for i in 0..<lhs.count {
                if lhs[i] != rhs[rhs.index(rhs.startIndex, offsetBy: i)].asciiValue {
                    return false
                }
            }
            return true
        } else if lhs.count > stringCount {
            var i = 0
            while i < stringCount {
                if lhs[i] != rhs[rhs.index(rhs.startIndex, offsetBy: i)].asciiValue {
                    return false
                }
                i += 1
            }
            return lhs[i] == 0
        } else {
            return false
        }
    }

    @inlinable
    public func stringRepresentationsAreEqual<let secondCount: Int>(_ array: InlineArray<secondCount, Element>) -> Bool {
        let minCount = min(count, secondCount)
        var i = startIndex
        while i < minCount {
            if self[i] != array[i] {
                return false
            }
            i += 1
        }
        if count == secondCount {
            return true
        }
        return count > secondCount ? self[i] == 0 : array[i] == 0
    }
}

// MARK: Pattern matching
extension InlineArray where Element: Equatable {
    @inlinable
    public static func ~= (lhs: Self, rhs: Self) -> Bool {
        return lhs == rhs
    }
}
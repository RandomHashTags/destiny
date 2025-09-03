
import VariableLengthArray

extension VLArray: InlineArrayProtocol {
    public init(repeating value: Element) {
        fatalError("not supported")
    }

    #if Inlinable
    @inlinable
    #endif
    public func itemAt(index: Int) -> Element {
        self[index]
    }

    #if Inlinable
    @inlinable
    #endif
    public mutating func setItemAt(index: Int, element: Element) {
        self[index] = element
    }

    #if Inlinable
    @inlinable
    #endif
    public func withUnsafeBufferPointer<E: Error, R>(_ body: (UnsafeBufferPointer<Element>) throws(E) -> R) throws(E) -> R {
        return try body(UnsafeBufferPointer.init(storage))
    }
}

// MARK: init
extension InlineArrayProtocol {
    /// - Complexity: O(*n*) where _n_ is the length of the collection.
    #if Inlinable
    @inlinable
    #endif
    public init(_ array: some Collection<Element>) {
        self = .init(repeating: array[array.startIndex])
        for i in self.indices {
            self.setItemAt(index: i, element: array[array.index(array.startIndex, offsetBy: i)])
        }
    }
}
extension InlineArrayProtocol where Element == UInt8 {
    /// - Complexity: O(*n*) where _n_ is the length of the collection.
    #if Inlinable
    @inlinable
    #endif
    public init(_ utf8: String.UTF8View) {
        self = .init(repeating: 0)
        for i in self.indices {
            self.setItemAt(index: i, element: utf8[utf8.index(utf8.startIndex, offsetBy: i)])
        }
    }

    /// - Complexity: O(*n*) where _n_ is the length of the collection.
    #if Inlinable
    @inlinable
    #endif
    public init(_ simd: some SIMD<Element>) {
        self = .init(repeating: 0)
        for i in simd.indices {
            self.setItemAt(index: i, element: simd[i])
        }
    }
}

// MARK: split
extension InlineArrayProtocol where Element: Equatable {
    /// - Complexity: O(*n*) where _n_ is the length of the collection.
    #if Inlinable
    @inlinable
    #endif
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
    #if Inlinable
    @inlinable
    #endif
    public func split<let sliceLength: Int>(
        separators: Element...,
        defaultValue: Element,
        offset: Index = 0,
        yield: (InlineArray<sliceLength, Element>) throws(AnyError) -> Void
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

// MARK: Split VLArray
extension InlineArrayProtocol where Element == UInt8 {
    /// - Parameters:
    ///   - yield: Yields a slice of the result; returns whether or not to continue splitting.
    /// - Complexity: O(1)
    #if Inlinable
    @inlinable
    #endif
    public func split(
        separator: Element,
        defaultValue: Element,
        offset: Index = 0,
        yield: (inout VLArray<Element>) throws(AnyError) -> Bool
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

    #if Inlinable
    @inlinable
    #endif
    func splitSIMD64(
        separator: Element,
        separatorSIMD: SIMD64<UInt8>,
        noSeparatorFoundMask: SIMDMask<SIMD64<UInt8>.MaskStorage>,
        beginning: inout Index,
        index: inout Index,
        yield: (inout VLArray<Element>) throws(AnyError) -> Bool
    ) rethrows {
        let buffer = simd64(startIndex: index)
        if (buffer .== separatorSIMD) == noSeparatorFoundMask {
            index += 64
        } else {
            try splitSIMD32(separator: separator, separatorSIMD: separatorSIMD, noSeparatorFoundMask: noSeparatorFoundMask, beginning: &beginning, index: &index, yield: yield)
        }
    }

    #if Inlinable
    @inlinable
    #endif
    func splitSIMD32(
        separator: Element,
        separatorSIMD: SIMD64<UInt8>,
        noSeparatorFoundMask: SIMDMask<SIMD64<UInt8>.MaskStorage>,
        beginning: inout Index,
        index: inout Index,
        yield: (inout VLArray<Element>) throws(AnyError) -> Bool
    ) rethrows {
        let mask:SIMDMask<SIMD32<UInt8>.MaskStorage> = withUnsafeBytes(of: noSeparatorFoundMask, { $0.baseAddress!.bindMemory(to: SIMDMask<SIMD32<UInt8>.MaskStorage>.self, capacity: 32).pointee })
        let buffer = simd32(startIndex: index)
        if (buffer .== separatorSIMD.lowHalf) == mask {
            index += 32
        } else {
            try splitSIMD16(separator: separator, separatorSIMD: separatorSIMD, noSeparatorFoundMask: noSeparatorFoundMask, beginning: &beginning, index: &index, yield: yield)
        }
    }

    #if Inlinable
    @inlinable
    #endif
    func splitSIMD16(
        separator: Element,
        separatorSIMD: SIMD64<UInt8>,
        noSeparatorFoundMask: SIMDMask<SIMD64<UInt8>.MaskStorage>,
        beginning: inout Index,
        index: inout Index,
        yield: (inout VLArray<Element>) throws(AnyError) -> Bool
    ) rethrows {
        let mask:SIMDMask<SIMD16<UInt8>.MaskStorage> = withUnsafeBytes(of: noSeparatorFoundMask, { $0.baseAddress!.bindMemory(to: SIMDMask<SIMD16<UInt8>.MaskStorage>.self, capacity: 16).pointee })
        let buffer = simd16(startIndex: index)
        if (buffer .== separatorSIMD.lowHalf.lowHalf) == mask {
            index += 16
        } else {
            try splitSIMD8(separator: separator, separatorSIMD: separatorSIMD, noSeparatorFoundMask: noSeparatorFoundMask, beginning: &beginning, index: &index, yield: yield)
        }
    }

    #if Inlinable
    @inlinable
    #endif
    func splitSIMD8(
        separator: Element,
        separatorSIMD: SIMD64<UInt8>,
        noSeparatorFoundMask: SIMDMask<SIMD64<UInt8>.MaskStorage>,
        beginning: inout Index,
        index: inout Index,
        yield: (inout VLArray<Element>) throws(AnyError) -> Bool
    ) rethrows {
        let mask:SIMDMask<SIMD8<UInt8>.MaskStorage> = withUnsafeBytes(of: noSeparatorFoundMask, { $0.baseAddress!.bindMemory(to: SIMDMask<SIMD8<UInt8>.MaskStorage>.self, capacity: 8).pointee })
        let buffer = simd8(startIndex: index)
        if (buffer .== separatorSIMD.lowHalf.lowHalf.lowHalf) == mask {
            index += 8
        } else {
            try splitSIMD4(separator: separator, separatorSIMD: separatorSIMD, noSeparatorFoundMask: noSeparatorFoundMask, beginning: &beginning, index: &index, yield: yield)
        }
    }

    #if Inlinable
    @inlinable
    #endif
    func splitSIMD4(
        separator: Element,
        separatorSIMD: SIMD64<UInt8>,
        noSeparatorFoundMask: SIMDMask<SIMD64<UInt8>.MaskStorage>,
        beginning: inout Index,
        index: inout Index,
        yield: (inout VLArray<Element>) throws(AnyError) -> Bool
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

    #if Inlinable
    @inlinable
    #endif
    func yieldInlineVLArray(
        capacity: Int,
        beginning: inout Index,
        index: inout Index,
        defaultValue: Element,
        yield: (inout VLArray<Element>) throws(AnyError) -> Bool
    ) rethrows -> Bool {
        var continueYielding = true
        try VLArray<Element>.create(amount: capacity, default: defaultValue, {
            var array = $0
            var arrayIndex = 0
            var i = beginning
            while i < index {
                array[arrayIndex] = self.itemAt(index: i)
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
    /// - Complexity: O(*n*) where _n_ is the length of the collection.
    #if Inlinable
    @inlinable
    #endif
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
    /// - Complexity: O(*n*) where _n_ is the length of the collection.
    #if Inlinable
    @inlinable
    #endif
    public func firstSlice<let sliceLength: Int>(
        separator: Element,
        defaultValue: Element,
        offset: Index = 0
    ) -> (slice: InlineArray<sliceLength, Element>, index: Index) {
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

    /// - Complexity: O(*n*) where _n_ is the length of the collection.
    #if Inlinable
    @inlinable
    #endif
    public func firstSlice(
        separator: Element,
        defaultValue: Element,
        offset: Index = 0,
        _ closure: (_ slice: borrowing VLArray<Element>, _ index: Index) -> Void
    ) {
        let index = firstIndex(of: separator, offset: offset) ?? endIndex
        VLArray<Element>.create(amount: offset.distance(to: index), default: defaultValue) {
            var array = $0
            var targetIndex = offset
            var i = 0
            while targetIndex < index {
                array[i] = self.itemAt(index: targetIndex)
                targetIndex += 1
                i += 1
            }
            closure(array, index)
        }
    }
}

// MARK: slice
extension InlineArrayProtocol {
    /// - Complexity: O(*n*) where _n_ is the length of the collection.
    #if Inlinable
    @inlinable
    #endif
    public func slice<let sliceLength: Int>(
        startIndex: Index,
        endIndex: Index,
        defaultValue: Element
    ) -> InlineArray<sliceLength, Element> {
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

// MARK: string
extension InlineArrayProtocol where Self: ~Copyable, Element == UInt8 {
    #if Inlinable
    @inlinable
    #endif
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

    #if Inlinable
    @inlinable
    #endif
    public func unsafeString() -> String {
        return self.withUnsafeBufferPointer { pointer in
            return String.init(unsafeUninitializedCapacity: pointer.count, initializingUTF8With: {
                return $0.initialize(from: pointer).index
            })
        }
    }
}

// MARK: SIMD
extension InlineArrayProtocol where Element: SIMDScalar {
    /// - Complexity: O(1)
    #if Inlinable
    @inlinable
    #endif
    public func simd4(startIndex: Index = 0) -> SIMD4<Element> {
        simd(startIndex: startIndex)
    }

    /// - Complexity: O(1)
    #if Inlinable
    @inlinable
    #endif
    public func simd8(startIndex: Index = 0) -> SIMD8<Element> {
        simd(startIndex: startIndex)
    }

    /// - Complexity: O(1)
    #if Inlinable
    @inlinable
    #endif
    public func simd16(startIndex: Index = 0) -> SIMD16<Element> {
        simd(startIndex: startIndex)
    }

    /// - Complexity: O(1)
    #if Inlinable
    @inlinable
    #endif
    public func simd32(startIndex: Index = 0) -> SIMD32<Element> {
        simd(startIndex: startIndex)
    }

    /// - Complexity: O(1)
    #if Inlinable
    @inlinable
    #endif
    public func simd64(startIndex: Index = 0) -> SIMD64<Element> {
        simd(startIndex: startIndex)
    }

    /// Efficiently copies the elements to a type conforming to `SIMD where SIMD.Scalar == Element`.
    /// 
    /// - Parameters:
    ///   - startIndex: Where the first element is located.
    /// - Complexity: O(1)
    #if Inlinable
    @inlinable
    #endif
    public func simd<T: SIMD>(startIndex: Index = 0) -> T where T.Scalar == Element {
        var result = T()
        #if canImport(Android) || canImport(Bionic) || canImport(Darwin) || canImport(SwiftGlibc) || canImport(Musl) || canImport(WASILibc) || canImport(Windows) || canImport(WinSDK)
        withUnsafeBytes(of: self, { this in 
            withUnsafeBytes(of: &result, {
                copyMemory(.init(mutating: $0.baseAddress!), this.baseAddress! + startIndex, T.scalarCount)
            })
        })
        #else
        var i = startIndex
        for indice in 0..<T.scalarCount {
            result[indice] = itemAt(index: indice)
            i += 1
        }
        #endif
        return result
    }
}

// MARK: Equatable
extension InlineArrayProtocol where Element: Equatable {
    /// - Complexity: O(*n*) where _n_ is the length of the collection.
    #if Inlinable
    @inlinable
    #endif
    public static func == (lhs: Self?, rhs: Self) -> Bool {
        guard let lhs else { return false }
        return lhs == rhs
    }

    /// - Complexity: O(*n*) where _n_ is the length of the collection.
    #if Inlinable
    @inlinable
    #endif
    public static func == (lhs: Self, rhs: Self?) -> Bool {
        guard let rhs else { return false }
        return lhs == rhs
    }

    /// - Complexity: O(*n*) where _n_ is the length of the collection.
    #if Inlinable
    @inlinable
    #endif
    public static func == (lhs: Self, rhs: Self) -> Bool {
        for i in lhs.indices {
            if lhs.itemAt(index: i) != rhs.itemAt(index: i) {
                return false
            }
        }
        return true
    }

    /// - Complexity: O(*n*) where _n_ is the length of the collection.
    #if Inlinable
    @inlinable
    #endif
    public func equals<T: InlineArrayProtocol>(_ array: T) -> Bool where Element == T.Element {
        guard count == array.count else { return false }
        for i in indices {
            if self.itemAt(index: i) != array.itemAt(index: i) {
                return false
            }
        }
        return true
    }
}

extension InlineArrayProtocol where Element == UInt8 {
    #if Inlinable
    @inlinable
    #endif
    public static func == (lhs: Self, rhs: some StringProtocol) -> Bool {
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

    #if Inlinable
    @inlinable
    #endif
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
    /// - Complexity: O(*n*) where _n_ is the length of the collection.
    #if Inlinable
    @inlinable
    #endif
    public static func ~= (lhs: Self, rhs: Self) -> Bool {
        return lhs == rhs
    }
}
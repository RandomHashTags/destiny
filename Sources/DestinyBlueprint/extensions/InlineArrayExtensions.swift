
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

    #if Inlinable
    @inlinable
    #endif
    public func unsafeString(offset: Int) -> String {
        return self.withUnsafeBufferPointer {
            let count = $0.count - offset
            let slice = $0[offset...]
            return String.init(unsafeUninitializedCapacity: count - offset, initializingUTF8With: {
                return $0.initialize(from: slice).index
            })
        }
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
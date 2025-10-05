
// MARK: Addition
infix operator +!: AdditionPrecedence
infix operator +=!: AdditionPrecedence

/// Returns the sum of the two given values.
/// 
/// - Parameters:
///   - lhs: The first value to add.
///   - rhs: The second value to add.
/// 
/// - Note: Equivalent to `&+` if the package trait `OverflowAddition` is enabled, and `+` if disabled.
@inlinable
@inline(__always)
package func +! <T: FixedWidthInteger>(lhs: T, rhs: T) -> T {
    #if OverflowAddition
    lhs &+ rhs
    #else
    lhs + rhs
    #endif
}

/// Adds two values and stores the result in the left-hand-side variable.
/// 
/// - Parameters:
///   - lhs: The first value to add.
///   - rhs: The second value to add.
/// 
/// - Note: Equivalent to `&+=` if the package trait `OverflowAddition` is enabled, and `+=` if disabled.
@inlinable
@inline(__always)
package func +=! <T: FixedWidthInteger>(lhs: inout T, rhs: T) {
    #if OverflowAddition
    lhs &+= rhs
    #else
    lhs += rhs
    #endif
}

// MARK: Subtraction
infix operator -!: AdditionPrecedence
infix operator -=!: AdditionPrecedence

/// Returns the difference of the two given values.
/// 
/// - Parameters:
///   - lhs: A numeric value.
///   - rhs: The value to subtract from lhs.
/// 
/// - Note: Equivalent to `&-` if the package trait `OverflowSubtraction` is enabled, and `-` if disabled.
@inlinable
@inline(__always)
package func -! <T: FixedWidthInteger>(lhs: T, rhs: T) -> T {    
    #if OverflowSubtraction
    lhs &- rhs
    #else
    lhs - rhs
    #endif
}

/// Subtracts the second value from the first and stores the difference in the left-hand-side variable.
/// 
/// - Parameters:
///   - lhs: A numeric value.
///   - rhs: The value to subtract from lhs.
/// 
/// - Note: Equivalent to `&-=` if the package trait `OverflowSubtraction` is enabled, and `-=` if disabled.
@inlinable
@inline(__always)
package func -=! <T: FixedWidthInteger>(lhs: inout T, rhs: T) {
    #if OverflowSubtraction
    lhs &-= rhs
    #else
    lhs -= rhs
    #endif
}
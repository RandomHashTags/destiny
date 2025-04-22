
@freestanding(expression)
public macro inlineArray<let count: Int>(_ input: String) -> InlineArray<count, UInt8> = #externalMacro(module: "DestinyUtilityMacros", type: "InlineArrayMacro")

@freestanding(expression)
public macro inlineArray<let count: Int>(_ input: Int) -> InlineArray<count, UInt8> = #externalMacro(module: "DestinyUtilityMacros", type: "InlineArrayMacro")

@freestanding(expression)
public macro inlineArray<let count: Int>(count: Int, _ input: String) -> InlineArray<count, UInt8> = #externalMacro(module: "DestinyUtilityMacros", type: "InlineArrayMacro")

@freestanding(declaration, names: arbitrary)
macro httpResponseStatuses(
    _ entries: [(memberName: String, code: Int, phrase: String)]
) = #externalMacro(module: "DestinyUtilityMacros", type: "HTTPResponseStatusesMacro")
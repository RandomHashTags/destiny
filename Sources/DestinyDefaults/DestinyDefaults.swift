
public typealias DestinyRoutePathType = SIMD64<UInt8>

@freestanding(declaration, names: arbitrary)
macro httpRequestMethods(
    _ entries: [(memberName: String, method: String)]
) = #externalMacro(module: "DestinyUtilityMacros", type: "HTTPRequestMethods")
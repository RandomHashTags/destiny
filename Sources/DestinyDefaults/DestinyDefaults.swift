import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public typealias DestinyRoutePathType = SIMD64<UInt8>

@freestanding(declaration, names: arbitrary)
macro HTTPFieldContentType(
    category: String,
    values: [String:HTTPFieldContentTypeDetails]
) = #externalMacro(module: "DestinyUtilityMacros", type: "HTTPFieldContentType")

@freestanding(declaration, names: arbitrary)
macro httpRequestMethods(
    _ entries: [(memberName: String, method: String)]
) = #externalMacro(module: "DestinyUtilityMacros", type: "HTTPRequestMethods")

struct HTTPFieldContentTypeDetails {
    let httpValue:String
    let fileExtensions:Set<String>

    init(_ httpValue: String, fileExtensions: Set<String> = []) {
        self.httpValue = httpValue
        self.fileExtensions = fileExtensions
    }
}
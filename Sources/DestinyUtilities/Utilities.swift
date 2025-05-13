//
//  Utilities.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

@freestanding(declaration, names: arbitrary)
macro HTTPFieldContentType(
    category: String,
    values: [String:HTTPFieldContentTypeDetails]
) = #externalMacro(module: "DestinyUtilityMacros", type: "HTTPFieldContentType")

struct HTTPFieldContentTypeDetails {
    let httpValue:String
    let fileExtensions:Set<String>

    init(_ httpValue: String, fileExtensions: Set<String> = []) {
        self.httpValue = httpValue
        self.fileExtensions = fileExtensions
    }
}

public typealias DestinyRoutePathType = SIMD64<UInt8>
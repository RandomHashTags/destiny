//
//  HTTPMessage.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

import DestinyUtilities
import Foundation
import HTTPTypes
import SwiftSyntax
import SwiftSyntaxMacros

enum HTTPMessage : DeclarationMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        var version:HTTPVersion = .v1_1
        var status:HTTPResponse.Status = .notImplemented
        var headers:[String:String] = [:] // TODO: finish
        var result:RouteResult? = nil // TODO: finish
        var contentType:HTTPMediaType? = nil
        var charset:String? = nil
        for argument in node.as(ExprSyntax.self)!.macroExpansion!.arguments.children(viewMode: .all) {
            if let child:LabeledExprSyntax = argument.as(LabeledExprSyntax.self) {
                if let key:String = child.label?.text {
                    switch key {
                        case "version":
                            version = HTTPVersion.parse(child.expression) ?? version
                        case "status":
                            status = HTTPResponse.Status(expr: child.expression) ?? status
                        case "headers":
                            break
                        case "result":
                            break
                        case "contentType":
                            contentType = HTTPMediaType.parse(child.expression.memberAccess!.declName.baseName.text)
                        case "charset":
                            charset = child.expression.stringLiteral?.string ?? charset
                        default:
                            break
                    }
                }
            }
        }
        do {
            var response:String = try DestinyUtilities.HTTPMessage(version: version, status: status, headers: headers, result: result, contentType: contentType, charset: charset).string(escapeLineBreak: true)
            response = "\"" + response + "\""
            return ["\(raw: response)"]
        } catch {
            return []
        }
    }
}
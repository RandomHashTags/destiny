//
//  HTTPMessage.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

import DestinyUtilities
import SwiftSyntax
import SwiftSyntaxMacros

enum HTTPMessage : DeclarationMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        var version:HTTPVersion = .v1_1
        var status:HTTPResponseStatus = .notImplemented
        var headers:[String:String] = [:]
        var result:RouteResult? = nil
        var contentType:HTTPMediaType? = nil
        var charset:Charset? = nil
        for child in node.as(ExprSyntax.self)!.macroExpansion!.arguments {
            if let key:String = child.label?.text {
                switch key {
                    case "version":
                        version = HTTPVersion.parse(child.expression) ?? version
                    case "status":
                        status = HTTPResponseStatus(expr: child.expression) ?? status
                    case "headers":
                        headers = HTTPRequestHeader.parse(context: context, child.expression)
                    case "result":
                        result = RouteResult(expr: child.expression)
                    case "contentType":
                        contentType = HTTPMediaTypes.parse(child.expression.memberAccess!.declName.baseName.text)
                    case "charset":
                        charset = Charset(expr: child.expression)
                    default:
                        break
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
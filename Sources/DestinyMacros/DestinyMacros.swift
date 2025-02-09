//
//  DestinyMacros.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

#if canImport(SwiftCompilerPlugin) && canImport(SwiftDiagnostics) && canImport(SwiftSyntaxMacros)
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntaxMacros

// MARK: ErrorDiagnostic
struct DiagnosticMsg : DiagnosticMessage {
    let message:String
    let diagnosticID:MessageID
    let severity:DiagnosticSeverity

    init(id: String, message: String, severity: DiagnosticSeverity = .error) {
        self.message = message
        self.diagnosticID = MessageID(domain: "DestinyMacros", id: id)
        self.severity = severity
    }
}
extension DiagnosticMsg : FixItMessage {
    var fixItID : MessageID { diagnosticID }
}


@main
struct DestinyMacros : CompilerPlugin {
    let providingMacros:[any Macro.Type] = [
        Router.self,
        HTTPMessage.self
    ]
}
#endif
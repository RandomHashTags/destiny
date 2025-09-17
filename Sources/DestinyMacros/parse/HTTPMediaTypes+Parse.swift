
import DestinyBlueprint
import DestinyDefaults
import HTTPMediaTypes
import HTTPMediaTypeExtras
import SwiftSyntax
import SwiftSyntaxMacros

extension HTTPMediaType {
    public static func parse(memberName: String) -> Self? {
        if let v = HTTPMediaTypeApplication(rawValue: memberName) { return .init(type: v.type, subType: v.subType) }
        if let v = HTTPMediaTypeFont(rawValue: memberName) { return .init(type: v.type, subType: v.subType) }
        if let v = HTTPMediaTypeHaptics(rawValue: memberName) { return .init(type: v.type, subType: v.subType) }
        if let v = HTTPMediaTypeImage(rawValue: memberName) { return .init(type: v.type, subType: v.subType) }
        if let v = HTTPMediaTypeMessage(rawValue: memberName) { return .init(type: v.type, subType: v.subType) }
        if let v = HTTPMediaTypeModel(rawValue: memberName) { return .init(type: v.type, subType: v.subType) }
        if let v = HTTPMediaTypeMultipart(rawValue: memberName) { return .init(type: v.type, subType: v.subType) }
        if let v = HTTPMediaTypeText(rawValue: memberName) { return .init(type: v.type, subType: v.subType) }
        if let v = HTTPMediaTypeVideo(rawValue: memberName) { return .init(type: v.type, subType: v.subType) }
        return nil
    }

    public static func parse(fileExtension: String) -> Self? {
        if let v = HTTPMediaTypeApplication(fileExtension: fileExtension) { return .init(type: v.type, subType: v.subType) }
        if let v = HTTPMediaTypeFont(fileExtension: fileExtension) { return .init(type: v.type, subType: v.subType) }
        if let v = HTTPMediaTypeHaptics(fileExtension: fileExtension) { return .init(type: v.type, subType: v.subType) }
        if let v = HTTPMediaTypeImage(fileExtension: fileExtension) { return .init(type: v.type, subType: v.subType) }
        if let v = HTTPMediaTypeMessage(fileExtension: fileExtension) { return .init(type: v.type, subType: v.subType) }
        if let v = HTTPMediaTypeModel(fileExtension: fileExtension) { return .init(type: v.type, subType: v.subType) }
        if let v = HTTPMediaTypeMultipart(fileExtension: fileExtension) { return .init(type: v.type, subType: v.subType) }
        if let v = HTTPMediaTypeText(fileExtension: fileExtension) { return .init(type: v.type, subType: v.subType) }
        if let v = HTTPMediaTypeVideo(fileExtension: fileExtension) { return .init(type: v.type, subType: v.subType) }
        return nil
    }

    public static func parse(context: some MacroExpansionContext, expr: some ExprSyntaxProtocol) -> Self? {
        if let s = expr.memberAccess?.declName.baseName.text {
            return parse(memberName: s) ?? parse(fileExtension: s)
        } else if let function = expr.functionCall {
            if let type = function.arguments.first?.expression.stringLiteralString(context: context) {
                if let subType = function.arguments.last?.expression.stringLiteralString(context: context) {
                    return HTTPMediaType(type: type, subType: subType)
                }
            }
        } else {
            context.diagnose(DiagnosticMsg.expectedFunctionCallOrMemberAccessExpr(expr: expr))
        }
        return nil
    }
}
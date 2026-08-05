
import SwiftSyntax
import SwiftSyntaxMacros

public enum IntermediateResponseBodyType: Equatable, Sendable {
    case bytes
    case inlineBytes
    case macroExpansion
    case macroExpansionWithDateHeader
    case streamWithDateHeader

    case string(isNonCopyable: Bool, isStatic: Bool, withDateHeader: Bool, withCompressedBody: Bool)

    case nonCopyableBytes
    case nonCopyableInlineBytes
    case nonCopyableMacroExpansionWithDateHeader
    case nonCopyableStreamWithDateHeader
}

// MARK: Is enabled
extension IntermediateResponseBodyType {
    public var isEnabled: Bool {
        switch self {
        case .bytes:
            #if CopyableBytes
            return true
            #else
            return false
            #endif
        case .inlineBytes:
            #if CopyableInlineBytes
            return true
            #else
            return false
            #endif
        case .macroExpansion:
            #if CopyableMacroExpansion
            return true
            #else
            return false
            #endif
        case .macroExpansionWithDateHeader:
            #if CopyableMacroExpansionWithDateHeader
            return true
            #else
            return false
            #endif
        case .streamWithDateHeader:
            #if CopyableStreamWithDateHeader
            return true
            #else
            return false
            #endif

        case .string(let isNonCopyable, let isStatic, let withDateHeader, let withCompressedBody):
            if isNonCopyable {
                if isStatic {
                    if withDateHeader {
                        if withCompressedBody {
                            #if NonCopyableStaticStringWithDateHeader
                            return true
                            #else
                            return false
                            #endif
                        }
                        #if NonCopyableStaticStringWithDateHeader
                        return true
                        #else
                        return false
                        #endif
                    }
                }
            }
            // copyable
            if isStatic {
                if withDateHeader {
                    if withCompressedBody {
                        #if CopyableStaticStringWithDateHeader
                        return true
                        #else
                        return false
                        #endif
                    }
                    #if CopyableStringWithDateHeader
                    return true
                    #else
                    return false
                    #endif
                }
                return true
            }
            // copyable, not static
            if withDateHeader {
                #if CopyableStringWithDateHeader
                return true
                #else
                return false
                #endif
            }
            #if StringRouteResponder
            return true
            #else
            return false
            #endif

        case .nonCopyableBytes:
            #if NonCopyableBytes
            return true
            #else
            return false
            #endif
        case .nonCopyableInlineBytes:
            #if NonCopyableInlineBytes
            return true
            #else
            return false
            #endif
        case .nonCopyableMacroExpansionWithDateHeader:
            #if NonCopyableMacroExpansionWithDateHeader
            return true
            #else
            return false
            #endif
        case .nonCopyableStreamWithDateHeader:
            #if NonCopyableStreamWithDateHeader
            return true
            #else
            return false
            #endif
        }
    }
}

// MARK: Parse
extension IntermediateResponseBodyType {
    public static func parse(key: String, args: LabeledExprListSyntax) -> Self? {
        switch key {
        case "bytes": .bytes
        case "inlinebytes": .inlineBytes
        case "macroexpansion": .macroExpansion
        case "macroexpansionwithdateheader": .macroExpansionWithDateHeader
        case "streamWithDateHeader": .streamWithDateHeader
        case "noncopyablebytes": .nonCopyableBytes
        case "noncopyableinlinebytes": .nonCopyableInlineBytes
        case "noncopyablemacroexpansionwithdateheader": .nonCopyableMacroExpansionWithDateHeader
        case "noncopyablestreamwithdateheader": .nonCopyableStreamWithDateHeader
        default: nil
        }
    }
}
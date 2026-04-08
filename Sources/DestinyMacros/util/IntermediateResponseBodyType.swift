
public enum IntermediateResponseBodyType: String, Sendable {
    case bytes
    case inlineBytes                             = "inlinebytes"
    case macroExpansion                          = "macroexpansion"
    case macroExpansionWithDateHeader            = "macroexpansionwithdateheader"
    case streamWithDateHeader                    = "streamwithdateheader"
    case staticString                            = "staticstring"
    case staticStringWithDateHeader              = "staticstringwithdateheader"
    case stringWithDateHeader                    = "stringwithdateheader"

    case string

    case nonCopyableBytes                        = "noncopyablebytes"
    case nonCopyableInlineBytes                  = "noncopyableinlinebytes"
    case nonCopyableMacroExpansionWithDateHeader = "noncopyablemacroexpansionwithdateheader"
    case nonCopyableStreamWithDateHeader         = "noncopyablestreamwithdateheader"
    case nonCopyableStaticStringWithDateHeader   = "noncopyablestaticstringwithdateheader"
}

// MARK: Is enabled
extension IntermediateResponseBodyType {
    public var isEnabled: Bool {
        switch self {
        case .bytes:
            #if CopyableBytes
            true
            #else
            false
            #endif
        case .inlineBytes:
            #if CopyableInlineBytes
            true
            #else
            false
            #endif
        case .macroExpansion:
            #if CopyableMacroExpansion
            true
            #else
            false
            #endif
        case .macroExpansionWithDateHeader:
            #if CopyableMacroExpansionWithDateHeader
            true
            #else
            false
            #endif
        case .streamWithDateHeader:
            #if CopyableStreamWithDateHeader
            true
            #else
            false
            #endif
        case .staticString:
            true
        case .staticStringWithDateHeader:
            #if CopyableStaticStringWithDateHeader
            true
            #else
            false
            #endif
        case .stringWithDateHeader:
            #if CopyableStringWithDateHeader
            true
            #else
            false
            #endif

        case .string:
            #if StringRouteResponder
            true
            #else
            false
            #endif

        case .nonCopyableBytes:
            #if NonCopyableBytes
            true
            #else
            false
            #endif
        case .nonCopyableInlineBytes:
            #if NonCopyableInlineBytes
            true
            #else
            false
            #endif
        case .nonCopyableMacroExpansionWithDateHeader:
            #if NonCopyableMacroExpansionWithDateHeader
            true
            #else
            false
            #endif
        case .nonCopyableStreamWithDateHeader:
            #if NonCopyableStreamWithDateHeader
            true
            #else
            false
            #endif
        case .nonCopyableStaticStringWithDateHeader:
            #if NonCopyableStaticStringWithDateHeader
            true
            #else
            false
            #endif
        }
    }
}
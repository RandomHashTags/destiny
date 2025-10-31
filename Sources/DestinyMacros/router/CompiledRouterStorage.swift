
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

struct CompiledRouterStorage {
    #if RouterSettings
    let settings:RouterSettings
    #endif

    let settingsSyntax:ExprSyntax
    var perfectHashCaseSensitiveResponder:Responder? = nil
    var perfectHashCaseInsensitiveResponder:Responder? = nil

    var caseSensitiveResponder:Responder? = nil
    var caseInsensitiveResponder:Responder? = nil

    var dynamicCaseSensitiveResponder:Responder? = nil
    var dynamicCaseInsensitiveResponder:Responder? = nil

    var dynamicMiddlewareArray:[String] = []

    var errorResponder:Responder? = nil
    var dynamicNotFoundResponder:Responder? = nil
    var staticNotFoundResponder:Responder? = nil

    let visibilityModifier:DeclModifierSyntax
    let requestTypeSyntax:TypeSyntax

    #if RouterSettings
    init(routerSettings: RouterSettings) {
        self.settings = routerSettings
        settingsSyntax = ExprSyntax("Int(0)")
        visibilityModifier = routerSettings.visibility.modifierDecl
        requestTypeSyntax = routerSettings.requestTypeSyntax
    }
    init(
        settings: RouterSettings,
        settingsSyntax: ExprSyntax,
        perfectHashCaseSensitiveResponder: Responder?,
        perfectHashCaseInsensitiveResponder: Responder?,

        caseSensitiveResponder: Responder?,
        caseInsensitiveResponder: Responder?,
        dynamicCaseSensitiveResponder: Responder?,
        dynamicCaseInsensitiveResponder: Responder?,

        dynamicMiddlewareArray: [String],

        errorResponder: Responder?,
        dynamicNotFoundResponder: Responder?,
        staticNotFoundResponder: Responder?
    ) {
        self.settings = settings
        self.settingsSyntax = settingsSyntax
        self.perfectHashCaseSensitiveResponder = perfectHashCaseSensitiveResponder
        self.perfectHashCaseInsensitiveResponder = perfectHashCaseInsensitiveResponder

        self.caseSensitiveResponder = caseSensitiveResponder
        self.caseInsensitiveResponder = caseInsensitiveResponder
        self.dynamicCaseSensitiveResponder = dynamicCaseSensitiveResponder
        self.dynamicCaseInsensitiveResponder = dynamicCaseInsensitiveResponder

        self.dynamicMiddlewareArray = dynamicMiddlewareArray

        self.errorResponder = errorResponder
        self.dynamicNotFoundResponder = dynamicNotFoundResponder
        self.staticNotFoundResponder = staticNotFoundResponder
        visibilityModifier = settings.visibility.modifierDecl
        requestTypeSyntax = settings.requestTypeSyntax
    }
    #else
    init() {
        settingsSyntax = ExprSyntax("Int(0)")
        visibilityModifier = RouterVisibility.package.modifierDecl
        requestTypeSyntax = TypeSyntax(stringLiteral: "HTTPRequest")
    }
    init(
        settingsSyntax: ExprSyntax,
        perfectHashCaseSensitiveResponder: Responder?,
        perfectHashCaseInsensitiveResponder: Responder?,

        caseSensitiveResponder: Responder?,
        caseInsensitiveResponder: Responder?,
        dynamicCaseSensitiveResponder: Responder?,
        dynamicCaseInsensitiveResponder: Responder?,

        dynamicMiddlewareArray: [String],

        errorResponder: Responder?,
        dynamicNotFoundResponder: Responder?,
        staticNotFoundResponder: Responder?
    ) {
        self.settingsSyntax = settingsSyntax
        self.perfectHashCaseSensitiveResponder = perfectHashCaseSensitiveResponder
        self.perfectHashCaseInsensitiveResponder = perfectHashCaseInsensitiveResponder

        self.caseSensitiveResponder = caseSensitiveResponder
        self.caseInsensitiveResponder = caseInsensitiveResponder
        self.dynamicCaseSensitiveResponder = dynamicCaseSensitiveResponder
        self.dynamicCaseInsensitiveResponder = dynamicCaseInsensitiveResponder

        self.dynamicMiddlewareArray = dynamicMiddlewareArray

        self.errorResponder = errorResponder
        self.dynamicNotFoundResponder = dynamicNotFoundResponder
        self.staticNotFoundResponder = staticNotFoundResponder
        visibilityModifier = RouterVisibility.package.modifierDecl
        requestTypeSyntax = TypeSyntax(stringLiteral: "HTTPRequest")
    }
    #endif

    var isMutable: Bool {
        #if RouterSettings
        settings.isMutable
        #else
        false
        #endif
    }

    var hasProtocolConformances: Bool {
        #if RouterSettings
        settings.hasProtocolConformances
        #else
        true
        #endif
    }
    
    var visibility: RouterVisibility {
        #if RouterSettings
        settings.visibility
        #else
        .package
        #endif
    }

    var name: String {
        #if RouterSettings
        settings.name
        #else
        "CompiledHTTPRouter"
        #endif
    }

    var requestType: String {
        "HTTPRequest"
    }

    var hasLogging: Bool {
        #if RouterSettings
        settings.hasLogging
        #else
        false
        #endif
    }
}

// MARK: Responder
extension CompiledRouterStorage {
    struct Responder {
        static func get(_ copyable: String?, _ noncopyable: String?) -> Responder? {
            return copyable != nil || noncopyable != nil ? .init(copyable: copyable, noncopyable: noncopyable) : nil
        }

        let copyable:String?
        let noncopyable:String?
    }
}
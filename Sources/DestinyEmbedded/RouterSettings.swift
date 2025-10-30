
#if RouterSettings

/// Configurable settings that change how the auto-generated router behaves.
public struct RouterSettings: Sendable {
    /// Name of the compiled router's `struct`.
    public var name:String

    @usableFromInline
    var flags:Flags.RawValue

    /// Access control for the router.
    public var visibility:RouterVisibility

    public init(
        mutable: Bool = false,
        dynamicResponsesAreGeneric: Bool = true,
        respondersAreComputedProperties: Bool = false,
        protocolConformances: Bool = true,
        logging: Bool = true,
        visibility: RouterVisibility = .internal,
        name: String = "CompiledHTTPRouter"
    ) {
        self.visibility = visibility
        self.name = name
        flags = Flags.pack(
            mutable: mutable,
            dynamicResponsesAreGeneric: dynamicResponsesAreGeneric,
            respondersAreComputedProperties: respondersAreComputedProperties,
            protocolConformances: protocolConformances,
            logging: logging
        )
    }

    /// Whether or not this router is mutable.
    /// 
    /// If `true`: you can register middleware, routes, route groups, and route responders at runtime.
    /// 
    /// Default is `false`.
    public var isMutable: Bool {
        get { isFlag(.mutable) }
        set { setFlag(.mutable, newValue) }
    }

    /// Whether the expanded route responders should be computed properties instead of static constants.
    /// 
    /// Default is `false`.
    public var respondersAreComputedProperties: Bool {
        get { isFlag(.respondersAreComputedProperties) }
        set { setFlag(.respondersAreComputedProperties, newValue) }
    }

    /// Whether or not the default response for Dynamic Route Responders should be `GenericDynamicResponse`.
    /// 
    /// Default is `true`.
    public var dynamicResponsesAreGeneric: Bool {
        get { isFlag(.dynamicResponsesAreGeneric) }
        set { setFlag(.dynamicResponsesAreGeneric, newValue) }
    }

    /// Whether or not the expanded data inherits their relevant protocols.
    /// Can reduce binary size if disabled and handled properly.
    /// 
    /// Default is `true`.
    public var hasProtocolConformances: Bool {
        get { isFlag(.protocolConformances) }
        set { setFlag(.protocolConformances, newValue) }
    }

    /// Whether or not the expanded data should include logging logic.
    /// 
    /// Default is `true`.
    public var hasLogging: Bool {
        get { isFlag(.logging) }
        set { setFlag(.logging, newValue) }
    }
}

// MARK: Flags
extension RouterSettings {
    @usableFromInline
    enum Flags: UInt8 {
        case mutable = 1
        case dynamicResponsesAreGeneric = 2
        case respondersAreComputedProperties = 4
        case protocolConformances = 8
        case logging = 16

        static func pack(
            mutable: Bool,
            dynamicResponsesAreGeneric: Bool,
            respondersAreComputedProperties: Bool,
            protocolConformances: Bool,
            logging: Bool
        ) -> RawValue {
            (mutable ? Self.mutable.rawValue : 0)
            | (dynamicResponsesAreGeneric ? Self.dynamicResponsesAreGeneric.rawValue : 0)
            | (respondersAreComputedProperties ? Self.respondersAreComputedProperties.rawValue : 0)
            | (protocolConformances ? Self.protocolConformances.rawValue : 0)
            | (logging ? Self.logging.rawValue : 0)
        }
    }

    func isFlag(_ flag: Flags) -> Bool {
        flags & flag.rawValue != 0
    }

    mutating func setFlag(_ flag: Flags, _ value: Bool) {
        if value {
            flags |= flag.rawValue
        } else {
            flags &= ~flag.rawValue
        }
    }
}

#endif
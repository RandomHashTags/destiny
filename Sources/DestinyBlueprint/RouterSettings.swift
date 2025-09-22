
/// Configurable settings that change how the auto-generated router behaves.
public struct RouterSettings: Sendable {
    /// Name of the compiled router's `struct`.
    public var name:String

    /// Type used as the request storage.
    /// 
    /// - Warning: Must conform to `HTTPRequestProtocol`.
    public var requestType:String

    @usableFromInline
    var flags:Flags.RawValue

    /// Access control for the router.
    public var visibility:RouterVisibility

    public init(
        copyable: Bool = false,
        mutable: Bool = false,
        respondersAreComputedProperties: Bool = false,
        protocolConformances: Bool = true,
        visibility: RouterVisibility = .internal,
        name: String? = nil,
        requestType: String = "HTTPRequest"
    ) {
        self.visibility = visibility
        self.name = name ?? "CompiledHTTPRouter"
        self.requestType = requestType
        flags = Flags.pack(
            copyable: copyable,
            mutable: mutable,
            respondersAreComputedProperties: respondersAreComputedProperties,
            protocolConformances: protocolConformances
        )
    }

    /// Whether or not this router should conform to `Copyable`.
    #if Inlinable
    @inlinable
    #endif
    public var isCopyable: Bool {
        get { isFlag(.copyable) }
        set { setFlag(.copyable, newValue) }
    }

    /// Whether or not this router is mutable.
    /// 
    /// If `true`: you can register middleware, routes, route groups, and route responders at runtime.
    #if Inlinable
    @inlinable
    #endif
    public var isMutable: Bool {
        get { isFlag(.mutable) }
        set { setFlag(.mutable, newValue) }
    }

    #if Inlinable
    @inlinable
    #endif
    public var respondersAreComputedProperties: Bool {
        get { isFlag(.respondersAreComputedProperties) }
        set { setFlag(.respondersAreComputedProperties, newValue) }
    }

    #if Inlinable
    @inlinable
    #endif
    public var hasProtocolConformances: Bool {
        get { isFlag(.protocolConformances) }
        set { setFlag(.protocolConformances, newValue) }
    }
}

// MARK: Flags
extension RouterSettings {
    @usableFromInline
    enum Flags: UInt8 {
        case copyable = 1
        case mutable  = 2
        case respondersAreComputedProperties = 4
        case protocolConformances = 8

        static func pack(
            copyable: Bool,
            mutable: Bool,
            respondersAreComputedProperties: Bool,
            protocolConformances: Bool
        ) -> RawValue {
            (copyable ? Self.copyable.rawValue : 0)
            | (mutable ? Self.mutable.rawValue : 0)
            | (respondersAreComputedProperties ? Self.respondersAreComputedProperties.rawValue : 0)
            | (protocolConformances ? Self.protocolConformances.rawValue : 0)
        }
    }

    #if Inlinable
    @inlinable
    #endif
    func isFlag(_ flag: Flags) -> Bool {
        flags & flag.rawValue != 0
    }

    #if Inlinable
    @inlinable
    #endif
    mutating func setFlag(_ flag: Flags, _ value: Bool) {
        if value {
            flags |= flag.rawValue
        } else {
            flags &= ~flag.rawValue
        }
    }
}
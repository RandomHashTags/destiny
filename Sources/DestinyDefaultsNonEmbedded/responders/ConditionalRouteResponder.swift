
import DestinyBlueprint

/// Default Conditional Route Responder implementation where multiple responders are computed at compile time, but only one should be selected based on the request.
public struct ConditionalRouteResponder: Sendable { // TODO: avoid existentials / support embedded
    public private(set) var staticConditions:[@Sendable (inout any HTTPRequestProtocol) -> Bool]
    public private(set) var staticResponders:[any StaticRouteResponderProtocol]
    public private(set) var dynamicConditions:[@Sendable (inout any HTTPRequestProtocol) -> Bool]
    public private(set) var dynamicResponders:[any DynamicRouteResponderProtocol]

    package var staticConditionsDescription = "[]"
    package var staticRespondersDescription = "[]"
    package var dynamicConditionsDescription = "[]"
    package var dynamicRespondersDescription = "[]"

    public init(
        staticConditions: [@Sendable (inout any HTTPRequestProtocol) -> Bool],
        staticResponders: [any StaticRouteResponderProtocol],
        dynamicConditions: [@Sendable (inout any HTTPRequestProtocol) -> Bool],
        dynamicResponders: [any DynamicRouteResponderProtocol]
    ) {
        self.staticConditions = staticConditions
        self.staticResponders = staticResponders
        self.dynamicConditions = dynamicConditions
        self.dynamicResponders = dynamicResponders
    }
}

// MARK: Respond
extension ConditionalRouteResponder {
    #if Inlinable
    @inlinable
    #endif
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        // TODO: fix
        /*
        var request:any HTTPRequestProtocol = request
        for (index, condition) in staticConditions.enumerated() {
            if condition(&request) {
                try await staticResponders[index].write(to: socket)
                return true
            }
        }
        for (index, condition) in dynamicConditions.enumerated() {
            if condition(&request) {
                let responder = dynamicResponders[index]
                var response = responder.defaultResponse()
                try await responder.respond(to: socket, request: &request, response: &response)
                //try await router.respondDynamically(received: received, loaded: loaded, socket: socket, request: &request, responder: dynamicResponders[index])
                return true
            }
        }*/
    }
}

// MARK: Conformances
extension ConditionalRouteResponder: ConditionalRouteResponderProtocol {}
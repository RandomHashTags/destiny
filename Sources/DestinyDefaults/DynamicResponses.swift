//
//  DynamicResponses.swift
//
//
//  Created by Evan Anderson on 11/6/24.
//

import DestinyUtilities

/// Default storage where Destiny handles dynamic routes.
public struct DynamicResponses : CustomDebugStringConvertible, Sendable {
    /// The dynamic routes without parameters.
    public var parameterless:[DestinyRoutePathType:any DynamicRouteResponderProtocol]

    /// The dynamic routes with parameters.
    public var parameterized:[[any DynamicRouteResponderProtocol]]

    public var catchall:[any DynamicRouteResponderProtocol]

    public init(
        parameterless: [DestinyRoutePathType:any DynamicRouteResponderProtocol],
        parameterized: [[any DynamicRouteResponderProtocol]],
        catchall: [any DynamicRouteResponderProtocol]
    ) {
        self.parameterless = parameterless
        self.parameterized = parameterized
        self.catchall = catchall
    }

    public var debugDescription : String {
        var parameterlessString:String = "[:]"
        if !parameterless.isEmpty {
            parameterlessString.removeLast(2)
            parameterlessString += "\n" + parameterless.map({ "// \($0.key.stringSIMD())\n\($0.key)" + ":" + $0.value.debugDescription }).joined(separator: ",\n") + "\n]"
        }
        var parameterizedString:String = "[]"
        if !parameterized.isEmpty {
            parameterizedString.removeLast()
            parameterizedString += "\n" + parameterized.map({ "[" + $0.map({ $0.debugDescription }).joined(separator: ",\n") + "\n]" }).joined(separator: ",\n") + "\n]"
        }
        var catchallString:String = "[]"
        if !catchall.isEmpty {
            catchallString.removeLast()
            catchallString += "\n" + catchall.map({ $0.debugDescription }).joined(separator: ",\n") + "\n]"
        }
        return """
        DynamicResponses(
            parameterless: \(parameterlessString),
            parameterized: \(parameterizedString),
            catchall: \(catchallString)
        )
        """
    }

    @inlinable
    public mutating func register(version: HTTPVersion, route: any DynamicRouteProtocol, responder: any DynamicRouteResponderProtocol, override: Bool) throws {
        if route.path.count(where: { $0.isParameter }) == 0 {
            var string:String = route.startLine
            let buffer:DestinyRoutePathType = DestinyRoutePathType(&string)
            if override || parameterless[buffer] == nil {
                parameterless[buffer] = responder
            } else {
                // TODO: throw error
            }
        } else {
            if parameterized.count <= route.path.count {
                for _ in parameterized.count...route.path.count {
                    parameterized.append([])
                }
            }
            parameterized[route.path.count].append(responder)
        }
    }

    @inlinable
    public func responder<Request: RequestProtocol>(for request: inout Request) -> (any DynamicRouteResponderProtocol)? {
        if let responder:any DynamicRouteResponderProtocol = parameterless[request.startLine] {
            return responder
        }
        let values:[String] = request.path
        guard let responders:[any DynamicRouteResponderProtocol] = parameterized.get(values.count) else { return catchallResponder(for: &request, values: values) }
        loop: for responder in responders {
            for i in 0..<values.count {
                let path:PathComponent = responder.path[i]
                if !path.isParameter && path.value != values[i] {
                    continue loop
                }
            }
            return responder
        }
        return catchallResponder(for: &request, values: values)
    }

    @inlinable
    func catchallResponder<Request: RequestProtocol>(for request: inout Request, values: [String]) -> (any DynamicRouteResponderProtocol)? {
        loop: for responder in catchall {
            for (i, path) in responder.path.enumerated() {
                if path == .catchall {
                    return responder
                } else if !path.isParameter && path.value != values[i] {
                    continue loop
                }
            }
        }
        return nil
    }
}

import DestinyBlueprint
import DestinyDefaults
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: Static routes string
extension Router.Storage {
    mutating func staticRoutesString(
        context: some MacroExpansionContext,
        isCaseSensitive: Bool,
        redirects: [(any RedirectionRouteProtocol, SyntaxProtocol)],
        middleware: [CompiledStaticMiddleware],
        _ routes: [(StaticRoute, FunctionCallExprSyntax)]
    ) -> String {
        guard !routes.isEmpty else { return "CompiledStaticResponderStorage(())" }
        var routeResponders = [String]()
        let getRouteStartLine:(StaticRoute) -> String = isCaseSensitive ? { $0.startLine } : { $0.startLine.lowercased() }
        let getRedirectRouteStartLine:(any RedirectionRouteProtocol) -> String = isCaseSensitive ? { route in
            return route.fromStartLine()
        } : { route in
            return route.fromStartLine().lowercased()
        }
        let getResponderValue:(Router.Storage.Route) -> String = {
            return "// \($0.path)\nCompiledStaticResponderStorageRoute(\npath: \($0.buffer),\nresponder: \($0.responder)\n)"
        }
        if !redirects.isEmpty {
            for (route, function) in redirects {
                var string = getRedirectRouteStartLine(route)
                if registeredPaths.contains(string) {
                    Router.routePathAlreadyRegistered(context: context, node: function, string)
                } else {
                    registeredPaths.insert(string)
                    do {
                        let responder = try StringWithDateHeader(route.response()).responderDebugDescription
                        routeResponders.append(getResponderValue(.init(path: string, buffer: .init(&string), responder: responder)))
                    } catch {
                        context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "staticRedirectError", message: "\(error)")))
                    }
                }
            }
        }
        for (route, function) in routes {
            do {
                var string = getRouteStartLine(route)
                if registeredPaths.contains(string) {
                    Router.routePathAlreadyRegistered(context: context, node: function, string)
                } else {
                    registeredPaths.insert(string)
                    let buffer = DestinyRoutePathType(&string)
                    let httpResponse = route.response(context: context, function: function, middleware: middleware)
                    if true /*route.supportedCompressionAlgorithms.isEmpty*/ {
                        if let responder = try responseBodyResponderDebugDescription(body: route.body, response: httpResponse) {
                            routeResponders.append(getResponderValue(.init(path: string, buffer: buffer, responder: responder)))
                        } else {
                            context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "failedToGetResponderDebugDescriptionForResponseBody", message: "Failed to get responder debug description for response body; body=\(String(describing: route.body));function=\(function.debugDescription)", severity: .warning)))
                        }
                    } else if let httpResponse = httpResponse as? HTTPResponseMessage {
                        Router.conditionalRoute(
                            context: context,
                            conditionalResponders: &conditionalResponders,
                            route: route,
                            function: function,
                            string: string,
                            buffer: buffer,
                            httpResponse: httpResponse
                        )
                    } else {
                        context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "unexpectedHTTPResponseMessage", message: "Router.Storage;staticRoutesString;conditionalRoute;httpResponse variable is not a HTTPResponseMessage")))
                    }
                }
            } catch {
                context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "staticRouteError", message: "\(error)")))
            }
        }
        var string = "CompiledStaticResponderStorage(\n(\n"
        for value in routeResponders {
            string += value + ",\n"
        }
        if !routeResponders.isEmpty { // was modified
            string.removeLast(2)
        }
        return string + "\n)\n)"
    }
    private func responseBodyResponderDebugDescription(
        body: (any ResponseBodyProtocol)?,
        response: any HTTPMessageProtocol
    ) throws -> String? {
        guard let body else { return nil }
        let s:String?
        if let v = body as? String {
            s = try v.responderDebugDescription(response)
        } else if let v = body as? StaticString {
            s = try v.responderDebugDescription(response)
        } else if let v = body as? StringWithDateHeader {
            s = try v.responderDebugDescription(response)
        } else if let v = body as? StaticStringWithDateHeader {
            s = try v.responderDebugDescription(response)
        } else if let v = body as? ResponseBody.Bytes {
            s = try v.responderDebugDescription(response)

        } else if let v = body as? ResponseBody.MacroExpansion<StaticString> {
            s = try v.responderDebugDescription(response)
        } else if let v = body as? ResponseBody.MacroExpansion<String> {
            s = try v.responderDebugDescription(response)
        
        } else if let v = body as? ResponseBody.MacroExpansionWithDateHeader<StaticString> {
            s = try v.responderDebugDescription(response)
        } else if let v = body as? ResponseBody.MacroExpansionWithDateHeader<String> {
            s = try v.responderDebugDescription(response)

        } else if let v = body as? ResponseBody.StreamWithDateHeader<StaticString> {
            s = try v.responderDebugDescription(response)
        } else if let v = body as? ResponseBody.StreamWithDateHeader<String> {
            s = try v.responderDebugDescription(response)

        } else if let v = body as? ResponseBody.StreamWithDateHeader<AsyncHTTPChunkDataStream<String>> {
            s = try v.responderDebugDescription(response)
        } else if let v = body as? ResponseBody.StreamWithDateHeader<AsyncHTTPChunkDataStream<StaticString>> {
            s = try v.responderDebugDescription(response)

        } else {
            s = nil
        }
        return s
    }
}
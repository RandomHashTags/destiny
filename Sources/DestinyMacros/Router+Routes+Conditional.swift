
import DestinyBlueprint
import DestinyDefaults
import SwiftSyntax
import SwiftSyntaxMacros

extension Router {
    static func conditionalRoute(
        context: some MacroExpansionContext,
        conditionalResponders: inout [RoutePath:any ConditionalRouteResponderProtocol],
        route: any RouteProtocol,
        function: FunctionCallExprSyntax,
        string: String,
        buffer: SIMD64<UInt8>,
        httpResponse: DestinyDefaults.HTTPResponseMessage
    ) {
        // TODO: refactor
        return;
        /*
        guard let result = httpResponse.body else { return }
        let body:[UInt8]
        do throws(HTTPMessageError) {
            body = try result.bytes()
        } catch {
            context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "httpResponseBytes", message: "Encountered error when getting the HTTPResponseMessage bytes: \(error).")))
            return
        }
        var httpResponse = httpResponse
        var responder = ConditionalRouteResponder(
            staticConditions: [],
            staticResponders: [],
            dynamicConditions: [],
            dynamicResponders: []
        )
        responder.staticConditionsDescription.removeLast() // ]
        responder.staticRespondersDescription.removeLast() // ]
        //responder.dynamicConditionsDescription.removeLast() // ] // TODO: support
        //responder.dynamicRespondersDescription.removeLast() // ]
        for algorithm in route.supportedCompressionAlgorithms {
            if let technique = algorithm.technique {
                do throws(AnyError) {
                    let compressed = try body.compressed(using: technique)
                    httpResponse.body = ResponseBody.bytes(compressed.data)
                    httpResponse.setHeader(key: HTTPResponseHeader.contentEncoding.rawNameString, value: algorithm.acceptEncodingName)
                    httpResponse.setHeader(key: HTTPResponseHeader.vary.rawNameString, value: HTTPRequestHeader.acceptEncoding.rawNameString)
                    do throws(HTTPMessageError) {
                        let bytes = try httpResponse.string(escapeLineBreak: false)
                        responder.staticConditionsDescription += "\n{ $0.headers[HTTPRequestHeader.acceptEncoding.rawNameString]?.contains(\"" + algorithm.acceptEncodingName + "\") ?? false }"
                        responder.staticRespondersDescription += "\n\(bytes)"
                    } catch {
                        context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "httpResponseBytes", message: "Encountered error when getting the HTTPResponseMessage bytes using the " + algorithm.rawValue + " compression algorithm: \(error).")))
                    }
                } catch {
                    context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "compressionError", message: "Encountered error while compressing bytes using the " + algorithm.rawValue + " algorithm: \(error).")))
                }
            } else {
                context.diagnose(Diagnostic(node: function, message: DiagnosticMsg(id: "noTechniqueForCompressionAlgorithm", message: "Failed to compress route data using the " + algorithm.rawValue + " algorithm.", severity: .warning)))
            }
        }
        responder.staticConditionsDescription += "\n]"
        responder.staticRespondersDescription += "\n]"
        conditionalResponders[RoutePath(comment: "// \(string)", path: buffer)] = responder*/
    }
}
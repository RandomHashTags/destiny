
import Destiny
import DestinySwiftSyntax
import Logging

package struct DestinyStorage {
}

// MARK: Destiny
extension DestinyStorage {
    #declareRouter(
        routerSettings: .init(
            visibility: .package,
            compression: .init(enabled: false)
        ),
        version: .v1_1,
        middleware: [
            StaticMiddleware(
                handlesMethods: [HTTPStandardRequestMethod.get],
                handlesContentTypes: ["text/html"],
                appliesStatus: HTTPStandardResponseStatus.ok.code,
                appliesHeaders: [
                    "server":"destiny",
                    "connection":"keep-alive"
                ]
            ),
            DynamicCORSMiddleware()
        ],
        Route.get(
            path: ["html"],
            contentType: "text/html",
            body: """
            <!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>
            """
        )
    )
}
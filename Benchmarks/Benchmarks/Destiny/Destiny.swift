
import DestinySwiftSyntax
import Logging

package struct DestinyStorage {
}

// MARK: Destiny
extension DestinyStorage {
    #declareRouter(
        routerSettings: .init(
            visibility: .package,
        ),
        version: .v1_1,
        middleware: [
            StaticMiddleware(
                handlesMethods: [HTTPStandardRequestMethod.get],
                handlesContentTypes: ["text/html"],
                appliesStatus: HTTPStandardResponseStatus.ok.code,
                appliesHeaders: [
                    "server":"destiny",
                    "connection":"close"
                ]
            )
        ],
        Route.get(
            path: ["html"],
            contentType: "text/html",
            body: NonCopyableStaticStringWithDateHeader(#"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"#)
        )
    )
}
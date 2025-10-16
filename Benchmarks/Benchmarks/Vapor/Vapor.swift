
import Vapor
import Utilities

package struct VaporStorage {
}

extension VaporStorage {
    package static func registerRoutes(_ app: Application) {
        let body = Response.Body(staticString: #"<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>"#)
        let headers = HTTPHeaders(dictionaryLiteral:
            ("server", "destiny"),
            ("connection", "close"),
            ("content-type", "text/html"),
            ("content-length", "132")
        )
        app.get(["html"]) { request in
            // we have to do it this way because its headers get updated every request (probably 'cause its a class)
            return Response(status: .ok, version: request.version, headers: headers, body: body)
        }
    } 
}
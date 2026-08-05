
import Hummingbird
import HummingbirdCompression
import Utilities

package struct HummingbirdStorage {
}

extension HummingbirdStorage {
    package static func router() -> Router<BasicRequestContext> {
        let router = Hummingbird.Router()
        //router.middlewares.add(ResponseCompressionMiddleware(minimumResponseSizeToCompress: 100))

        let body = Hummingbird.ResponseBody(byteBuffer: ByteBuffer(staticString: """
        <!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>This outcome was inevitable; t'was your destiny</h1></body></html>
        """))
        let headers = Hummingbird.HTTPFields(dictionaryLiteral:
            (.server, "destiny"),
            (.connection, "keep-alive"),
            (.contentType, "text/html")
        )
        let response = Hummingbird.Response(status: .ok, headers: headers, body: body)
        router.get("html") { request, _ in
            return response
        }
        return router
    }
}
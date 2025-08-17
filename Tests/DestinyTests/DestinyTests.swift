
import DestinySwiftSyntax
import Testing

struct DestinyTests {
    @Test
    func example() {
        #declareRouter(
            version: .v2_0,
            dynamicNotFoundResponder: nil,
            middleware: [
                StaticMiddleware(
                    handlesMethods: [HTTPStandardRequestMethod.get],
                    handlesContentTypes: [HTTPMediaTypeText.html],
                    appliesStatus: HTTPStandardResponseStatus.ok.code,
                    appliesHeaders: ["Are-You-My-Brother":"yes"]
                )
            ],
            StaticRoute.get(
                path: ["test1"],
                contentType: HTTPMediaTypeText.html,
                charset: Charset.utf8,
                body: ResponseBody.stringWithDateHeader("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>")
            ),
            StaticRoute.get(
                path: ["test2"],
                status: HTTPStandardResponseStatus.movedPermanently.code,
                contentType: HTTPMediaTypeText.html,
                charset: .utf8,
                body: ResponseBody.stringWithDateHeader("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>")
            ),
            StaticRoute.get(
                path: ["test3"],
                contentType: HTTPMediaTypeText.html,
                charset: .utf8,
                body: ResponseBody.bytes([UInt8]("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>".utf8))
            ),
            /*StaticRoute.get(
                path: ["test4"],
                contentType: HTTPMediaTypeText.html,
                charset: .utf8,
                body: ResponseBody.bytes16([UInt16]("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>".utf16))
            )*/
        )
    }
}
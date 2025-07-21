
import Destiny
import Testing

struct DestinyTests {
    @Test
    func example() {
        #declareRouter(
            version: .v2_0,
            dynamicNotFoundResponder: nil,
            middleware: [
                StaticMiddleware(
                    handlesMethods: [HTTPRequestMethod.get],
                    handlesContentTypes: [HTTPMediaType.textHtml],
                    appliesStatus: HTTPResponseStatus.ok.code,
                    appliesHeaders: ["Are-You-My-Brother":"yes"]
                )
            ],
            StaticRoute(
                method: HTTPRequestMethod.get,
                path: ["test1"],
                contentType: HTTPMediaType.textHtml,
                charset: Charset.utf8,
                body: ResponseBody.stringWithDateHeader("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>")
            ),
            StaticRoute(
                method: HTTPRequestMethod.get,
                path: ["test2"],
                status: HTTPResponseStatus.movedPermanently,
                contentType: HTTPMediaType.textHtml,
                charset: .utf8,
                body: ResponseBody.stringWithDateHeader("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>")
            ),
            StaticRoute(
                method: HTTPRequestMethod.get,
                path: ["test3"],
                contentType: HTTPMediaType.textHtml,
                charset: .utf8,
                body: ResponseBody.bytes([UInt8]("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>".utf8))
            ),
            /*StaticRoute(
                method: HTTPRequestMethod.get,
                path: ["test4"],
                contentType: HTTPMediaType.textHtml,
                charset: .utf8,
                body: ResponseBody.bytes16([UInt16]("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>".utf16))
            )*/
        )
    }

    @Test
    func inlineArrayVL() {
        InlineVLArray<UInt8>.create(amount: 5, default: 0, { array in
            #expect(array.count == 5)
            for i in array.indices {
                #expect(array.itemAt(index: i) == 0)
            }
        })
        InlineVLArray<UInt8>.create(amount: 3, default: 1, { array in
            #expect(array.count == 3)
            for i in array.indices {
                #expect(array.itemAt(index: i) == 1)
            }
        })
        var amount = 25
        InlineVLArray<UInt8>.create(amount: amount, default: 65, { array in
            #expect(array.count == amount)
            for i in array.indices {
                #expect(array.itemAt(index: i) == 65)
            }
        })
        amount /= 2
        InlineVLArray<UInt8>.create(amount: amount, default: 128, { array in
            #expect(array.count == amount)
            for i in array.indices {
                #expect(array.itemAt(index: i) == 128)
            }
        })

        InlineVLArray<UInt8>.create(string: "loopy__________doopy", { array in
            #expect(array.count == 20)
            #expect(array.itemAt(index: 0) == Character("l").asciiValue)
            #expect(array.itemAt(index: 1) == Character("o").asciiValue)
            #expect(array.itemAt(index: 2) == Character("o").asciiValue)
            #expect(array.itemAt(index: 3) == Character("p").asciiValue)
            #expect(array.itemAt(index: 4) == Character("y").asciiValue)
            #expect(array.itemAt(index: 5) == Character("_").asciiValue)
        })
    }

    @Test
    func joinedInlineArrayVL() throws {
        InlineVLArray<UInt8>.create(amount: 5, default: 0) { first in
            InlineVLArray<UInt8>.create(amount: 6, default: 1) { second in
                first.join([second]) { joined in
                    #expect(joined.capacity == 11)
                    for i in first.indices {
                        #expect(joined.elementAt(index: i) == 0)
                    }
                    let offset = first.count
                    #expect(offset == 5)
                    for i in second.indices {
                        #expect(joined.elementAt(index: offset + i) == 1)
                    }
                }
            }
        }
    }
}
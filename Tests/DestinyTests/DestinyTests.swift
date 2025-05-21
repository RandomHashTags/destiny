
import Destiny
import SwiftCompression
import Testing

struct DestinyTests {
    @Test func memoryLayouts() {
        //print(layout(for: RouteProtocol.self))
        //print("from: \(layout(for: Test1.self))")
        //print("to: \(layout(for: DynamicRoute.self))")
    }
    func layout<T>(for type: T.Type) -> (Int, Int, Int) {
        return (
            MemoryLayout<T>.alignment,
            MemoryLayout<T>.size,
            MemoryLayout<T>.stride
        )
    }

    struct Test1 {
        public let version:HTTPVersion
        public var method:HTTPRequestMethod
        public var path:[PathComponent]
        public var status:HTTPResponseStatus
        public var contentType:HTTPMediaType
        public var defaultResponse:any DynamicResponseProtocol
        public var supportedCompressionAlgorithms:Set<CompressionAlgorithm>
        public let handler:@Sendable (_ request: inout any RequestProtocol, _ response: inout any DynamicResponseProtocol) async throws -> Void
        var handlerLogic:String = "{ _, _ in }"
    }

    @Test func example() {
        let _:DefaultRouter = #router(
            version: .v2_0,
            middleware: [
                StaticMiddleware(handlesMethods: [.get], handlesContentTypes: [HTTPMediaType.textHtml], appliesStatus: HTTPResponseStatus.ok.code, appliesHeaders: ["Are-You-My-Brother":"yes"])
            ],
            StaticRoute(
                method: .get,
                path: ["test1"],
                contentType: HTTPMediaType.textHtml,
                charset: Charset.utf8,
                result: .staticString("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>")
            ),
            StaticRoute(
                method: .get,
                path: ["test2"],
                status: HTTPResponseStatus.movedPermanently,
                contentType: HTTPMediaType.textHtml,
                charset: .utf8,
                result: .staticString("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>")
            ),
            StaticRoute(
                method: .get,
                path: ["test3"],
                contentType: HTTPMediaType.textHtml,
                charset: .utf8,
                result: .bytes([UInt8]("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>".utf8))
            ),
            StaticRoute(
                method: .get,
                path: ["test4"],
                contentType: HTTPMediaType.textHtml,
                charset: .utf8,
                result: .bytes16([UInt16]("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>".utf16))
            )
        )
    }

    @Test func inlineArrayVL() {
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

    @Test func joinedInlineArrayVL() throws {
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

import Foundation
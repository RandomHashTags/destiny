
import Destiny
import Testing

@Suite
struct PathComponentTests {
    func willRespond(
        pathComponents: [PathComponent],
        requestPaths: [String]
    ) -> Bool {
        let requestPathCount = requestPaths.count
        loop: for i in 0..<pathComponents.count {
            let path = pathComponents[i]
            switch path {
            case .catchall:
                return true
            case .literal(let l):
                guard requestPathCount > i else { return false }
                let pathAtIndex = requestPaths[i]
                if l != pathAtIndex {
                    return false
                }
            case .parameter:
                break
            case .components(let l, let r):
                guard requestPathCount > i else { return false }
                let pathAtIndex = requestPaths[i]
                var readIndex = 0
                if !testTheThing(substring: Substring(pathAtIndex), readIndex: &readIndex, leftComponent: l, rightComponent: r) {
                    return false
                }
            }
        }
        return true
    }
    private func testTheThing(
        substring: Substring,
        readIndex: inout Int,
        leftComponent: PathComponent,
        rightComponent: PathComponent?
    ) -> Bool {
        switch leftComponent {
        case .literal(let pathPrefix): // has prefix
            guard substring.hasPrefix(pathPrefix) else { return false }
            readIndex += pathPrefix.utf8Span.count
            switch rightComponent {
            case .parameter:
                break
            case .components(let inner, let outer):
                let ss = substring[substring.index(substring.startIndex, offsetBy: pathPrefix.utf8Span.count)...]
                if !testTheThing(substring: ss, readIndex: &readIndex, leftComponent: inner, rightComponent: outer) {
                    return false
                }
            default:
                return false
            }
        case .parameter: // is the prefix
            switch rightComponent {
            case .literal(let pathSuffix):
                guard substring.hasSuffix(pathSuffix) else { return false }
                break
            default:
                break
            }
        default:
            return false
        }
        return true
    }
}

extension PathComponentTests {
    @Test
    func pathComponentLiteral() {
        #expect(willRespond(pathComponents: ["yessir"], requestPaths: ["yessir"]))
        #expect(!willRespond(pathComponents: ["yessir"], requestPaths: ["yes", "sir"]))

        #expect(willRespond(pathComponents: ["yeSsir"], requestPaths: ["yeSsir"]))
        #expect(!willRespond(pathComponents: ["yeSsir"], requestPaths: ["yeS", "sir"]))

        #expect(!willRespond(pathComponents: ["yeSsir"], requestPaths: ["yessir"]))
        #expect(!willRespond(pathComponents: ["yessir"], requestPaths: ["yeSsir"]))
    }

    @Test
    func pathComponentParameter() {
        #expect(willRespond(pathComponents: ["yes", ":sir"], requestPaths: ["yes", "sir"]))
        #expect(!willRespond(pathComponents: ["yes", ":sir"], requestPaths: ["yeS", "sir"]))

        #expect(willRespond(pathComponents: [":yes", "sir"], requestPaths: ["yeS", "sir"]))
        #expect(!willRespond(pathComponents: [":yes", "sir"], requestPaths: ["yes", "Sir"]))        
    }

    @Test
    func pathComponentCatchall() {
        #expect(willRespond(pathComponents: ["wtf", "**"], requestPaths: ["wtf", "sounds"]))
        #expect(willRespond(pathComponents: ["wtf", "**"], requestPaths: ["wtf", "sounds", "like", "alot", "of", "hoopla"]))
        #expect(willRespond(pathComponents: ["**", "dude"], requestPaths: ["wtf", "dude"]))
        #expect(willRespond(pathComponents: ["**", "dude", "um"], requestPaths: ["wtf", "um", "dude"]))
    }

    @Test
    func pathComponentComponents() {
        #expect(willRespond(pathComponents: ["{type}.zip"], requestPaths: ["file.zip"]))
        #expect(willRespond(pathComponents: ["file.{extension}"], requestPaths: ["file.zip"]))
        #expect(willRespond(pathComponents: ["file{extension}.zip"], requestPaths: ["file.zip"]))
        #expect(willRespond(pathComponents: ["will-this", "{work}-first-try"], requestPaths: ["will-this", "work-first-try"]))

        #expect(willRespond(pathComponents: ["will-this-{work}-first-try"], requestPaths: ["will-this-work-first-try"]))
        #expect(willRespond(pathComponents: ["will-this-{a}-first-try"], requestPaths: ["will-this-work-first-try"]))
        #expect(willRespond(pathComponents: ["will-this-{work}-first-try"], requestPaths: ["will-this-fail-first-try"]))
        #expect(!willRespond(pathComponents: ["will-this-{work}-first-try"], requestPaths: ["will-this-work-second-try"]))
        #expect(!willRespond(pathComponents: ["will-this", "{work}-first-try"], requestPaths: ["will-this", "first-try"]))
    }
}
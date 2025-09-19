
import DestinyBlueprint
import DestinyMacros
import Testing

@Suite
struct RoutePathComponentTests {
    func stringToSIMD64(_ string: String) -> SIMD64<UInt8> {
        var simd = SIMD64<UInt8>.zero
        let span = string.utf8Span.span
        for i in 0..<span.count {
            simd[i] = span[i]
        }
        return simd
    }
}

extension RoutePathComponentTests {
    @Test
    func routePathComponentInitializationExpressibleByStringLiteral() {
        var component = RoutePathComponent(stringLiteral: "**")
        #expect(component == .catchall)

        component = .init(stringLiteral: "testbro")
        #expect(component == .literal(stringToSIMD64("testbro")))

        component = .init(stringLiteral: ":")
        #expect(component == .parameter)

        component = .init(stringLiteral: "*")
        #expect(component == .parameter)

        component = .init(stringLiteral: "brother?")
        #expect(component == .query([stringToSIMD64("brother")]))
    }
}

extension RoutePathComponentTests {
    var literalRoutePath: String {
        "this/is/a/really/long/route/path/that/will/be/parsed/correctly/100percent/of/the/time"
    }

    @Test
    func routePathComponentParseLiteral() throws {
        let path = literalRoutePath
        let paths = path.split(separator: "/")
        let components = RoutePathComponent.parse(path)
        try #require(components.count == paths.count)
        for i in 0..<paths.count {
            try #require(components[i] == .literal(stringToSIMD64(String(paths[i]))))
        }
    }
}

extension RoutePathComponentTests {
    @Test
    func routePathComponentParseParameter() throws {
        let path = "what/in/tar/nation/:test/yup"
        let components = RoutePathComponent.parse(path)
        try #require(components.count == 6, "\(components)")
        #expect(components[0] == .literal(stringToSIMD64("what")))
        #expect(components[1] == .literal(stringToSIMD64("in")))
        #expect(components[2] == .literal(stringToSIMD64("tar")))
        #expect(components[3] == .literal(stringToSIMD64("nation")))
        #expect(components[4] == .parameter)
        #expect(components[5] == .literal(stringToSIMD64("yup")))
    }
}

extension RoutePathComponentTests {
    @Test
    func routePathComponentParseQuery() throws {
        let path = "what/in/tar/nation?test=yup"
        let components = RoutePathComponent.parse(path)
        try #require(components.count == 5, "\(components)")
        #expect(components[0] == .literal(stringToSIMD64("what")))
        #expect(components[1] == .literal(stringToSIMD64("in")))
        #expect(components[2] == .literal(stringToSIMD64("tar")))
        #expect(components[3] == .literal(stringToSIMD64("nation")))
        #expect(components[4] == .query([stringToSIMD64("test=yup")]))
    }
}

extension RoutePathComponentTests {
    @Test
    func routePathComponentParseCatchall() throws {
        let path = "what/in/**/nation/:test/yup"
        let components = RoutePathComponent.parse(path)
        try #require(components.count == 3, "\(components)")
        #expect(components[0] == .literal(stringToSIMD64("what")))
        #expect(components[1] == .literal(stringToSIMD64("in")))
        #expect(components[2] == .catchall)
    }
}

extension RoutePathComponentTests {
    @Test
    func routePathComponentParseParameterAndQuery() throws {
        let path = "what/in/tar/nation/:test/yuppers?/bruh"
        let components = RoutePathComponent.parse(path)
        try #require(components.count == 8, "\(components)")
        #expect(components[0] == .literal(stringToSIMD64("what")))
        #expect(components[1] == .literal(stringToSIMD64("in")))
        #expect(components[2] == .literal(stringToSIMD64("tar")))
        #expect(components[3] == .literal(stringToSIMD64("nation")))
        #expect(components[4] == .parameter)
        #expect(components[5] == .literal(stringToSIMD64("yuppers")))
        #expect(components[6] == .query([]))
        #expect(components[7] == .literal(stringToSIMD64("bruh")))
    }
}

extension RoutePathComponentTests {
    @Test
    func routePathComponentParseLiteralMoreThan64Characters() throws {
        var path = literalRoutePath.replacing("/", with: "_")
        path.append("/yuh")
        path.append("/AREA51")
        path.append("/lizard")
        let components = RoutePathComponent.parse(path)
        try #require(components.count == 5)
        #expect(components[0] == .literal(stringToSIMD64("this_is_a_really_long_route_path_that_will_be_parsed_correctly_1")))
        #expect(components[1] == .literal(stringToSIMD64("00percent_of_the_time")))
        #expect(components[2] == .literal(stringToSIMD64("yuh")))
        #expect(components[3] == .literal(stringToSIMD64("AREA51")))
        #expect(components[4] == .literal(stringToSIMD64("lizard")))
    }
}

extension RoutePathComponentTests {
    @Test
    func routePathComponentParseLiteralCompiled() throws {
        let path = literalRoutePath
        let components = RoutePathComponent.parse(path)
        let compiled = RoutePathComponent.parseCompiled(components)
        try #require(compiled.count == 2)
        let endIndex = path.index(path.startIndex, offsetBy: 64)
        #expect(compiled[0] == .literal(stringToSIMD64(String(path[path.startIndex..<endIndex]))))
        #expect(compiled[1] == .literal(stringToSIMD64(String(path[endIndex...]))))
    }
}
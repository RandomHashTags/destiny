
#if CORS

import Destiny
import Testing

@Suite
struct CORSMiddlewareTests {

    @Test
    func corsMiddlewareDefaults() {
        let middleware = CORSMiddleware()
        /*var expectedLogicKind = CORSLogic.maxAge(
            allowedHeaders: "accept,authorization,content-type,origin",
            allowedMethods: "GET,POST,PUT,OPTIONS,DELETE,PATCH",
            maxAge: "3600"
        )
        #expect(middleware.logicKind == expectedLogicKind)*/

        var headers = HTTPHeaders()
        middleware.logicKind.apply(to: &headers)
        //#expect(headers["access-control-allow-headers"] == "accept,authorization,content-type,origin")
        #expect(headers["access-control-allow-methods"] == "GET,POST,PUT,OPTIONS,DELETE,PATCH")
        #expect(headers["access-control-max-age"] == "3600")
        #expect(headers["access-control-allow-credentials"] == nil)
        #expect(headers["access-control-expose-headers"] == nil)
    }
}


/*
// MARK: Equatable
extension CORSLogic: Equatable {
    public static func == (lhs: CORSLogic, rhs: CORSLogic) -> Bool {
        switch lhs {
        case let .allowCredentials_exposedHeaders_maxAge(leftAllowedHeaders, leftAllowedMethods, leftExposedHeaders, leftMaxAge):
            guard case let .allowCredentials_exposedHeaders_maxAge(rightAllowedHeaders, rightAllowedMethods, rightExposedHeaders, rightMaxAge) = rhs else { return false }
            return leftAllowedHeaders == rightAllowedHeaders && leftAllowedMethods == rightAllowedMethods && leftExposedHeaders == rightExposedHeaders && leftMaxAge == rightMaxAge
        case let .allowCredentials_exposedHeaders(leftAllowedHeaders, leftAllowedMethods, leftExposedHeaders):
            guard case let .allowCredentials_exposedHeaders(rightAllowedHeaders, rightAllowedMethods, rightExposedHeaders) = rhs else { return false }
            return leftAllowedHeaders == rightAllowedHeaders && leftAllowedMethods == rightAllowedMethods && leftExposedHeaders == rightExposedHeaders
        case let .allowCredentials_maxAge(leftAllowedHeaders, leftAllowedMethods, leftMaxAge):
            guard case let .allowCredentials_maxAge(rightAllowedHeaders, rightAllowedMethods, rightMaxAge) = rhs else { return false }
            return leftAllowedHeaders == rightAllowedHeaders && leftAllowedMethods == rightAllowedMethods && leftMaxAge == rightMaxAge
        case let .allowCredentials(leftAllowedHeaders, leftAllowedMethods):
            guard case let .allowCredentials(rightAllowedHeaders, rightAllowedMethods) = rhs else { return false }
            return leftAllowedHeaders == rightAllowedHeaders && leftAllowedMethods == rightAllowedMethods
        case let .exposedHeaders_maxAge(leftAllowedHeaders, leftAllowedMethods, leftExposedHeaders, leftMaxAge):
            guard case let .exposedHeaders_maxAge(rightAllowedHeaders, rightAllowedMethods, rightExposedHeaders, rightMaxAge) = rhs else { return false }
            return leftAllowedHeaders == rightAllowedHeaders && leftAllowedMethods == rightAllowedMethods && leftExposedHeaders == rightExposedHeaders && leftMaxAge == rightMaxAge
        case let .exposedHeaders(leftAllowedHeaders, leftAllowedMethods, leftExposedHeaders):
            guard case let .exposedHeaders(rightAllowedHeaders, rightAllowedMethods, rightExposedHeaders) = rhs else { return false }
            return leftAllowedHeaders == rightAllowedHeaders && leftAllowedMethods == rightAllowedMethods && leftExposedHeaders == rightExposedHeaders
        case let .maxAge(leftAllowedHeaders, leftAllowedMethods, leftMaxAge):
            guard case let .maxAge(rightAllowedHeaders, rightAllowedMethods, rightMaxAge) = rhs else { return false }
            return leftAllowedHeaders == rightAllowedHeaders && leftAllowedMethods == rightAllowedMethods && leftMaxAge == rightMaxAge
        case let .minimum(leftAllowedHeaders, leftAllowedMethods):
            guard case let .minimum(rightAllowedHeaders, rightAllowedMethods) = rhs else { return false }
            return leftAllowedHeaders == rightAllowedHeaders && leftAllowedMethods == rightAllowedMethods
        }
    }
}*/

#endif
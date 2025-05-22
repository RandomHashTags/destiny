/*
import DestinyBlueprint

/// Default storage that handles static routes.
public struct CompiledStaticResponderStorage<
        let staticStringsCount: Int,
        let stringsCount: Int,
        let stringsWithDateHeaderCount: Int,
        let uint8ArraysCount: Int,
        let uint16ArraysCount: Int
    >: StaticResponderStorageProtocol {

    //let inlineArrays:InlineVLArray<Route<RouteResponses.InlineArrayProtocol>>
    public let staticStrings:InlineArray<staticStringsCount, Route<RouteResponses.StaticString>>
    public let strings:InlineArray<stringsCount, Route<RouteResponses.String>>
    public let stringsWithDateHeader:InlineArray<stringsWithDateHeaderCount, Route<RouteResponses.StringWithDateHeader>>
    public let uint8Arrays:InlineArray<uint8ArraysCount, Route<RouteResponses.UInt8Array>>
    public let uint16Arrays:InlineArray<uint16ArraysCount, Route<RouteResponses.UInt16Array>>

    #if canImport(FoundationEssentials) || canImport(Foundation)
    //public let foundationData:InlineVLArray<Route<RouteResponses.FoundationData>>
    #endif

    public init(
        //inlineArrays: [DestinyRoutePathType:RouteResponses.InlineArrayProtocol] = [:],
        staticStrings: InlineArray<staticStringsCount, Route<RouteResponses.StaticString>>,
        strings: InlineArray<stringsCount, Route<RouteResponses.String>>,
        stringsWithDateHeader: InlineArray<stringsWithDateHeaderCount, Route<RouteResponses.StringWithDateHeader>>,
        uint8Arrays: InlineArray<uint8ArraysCount, Route<RouteResponses.UInt8Array>>,
        uint16Arrays: InlineArray<uint16ArraysCount, Route<RouteResponses.UInt16Array>>
    ) {
        //self.inlineArrays = inlineArrays
        self.staticStrings = staticStrings
        self.strings = strings
        self.stringsWithDateHeader = stringsWithDateHeader
        self.uint8Arrays = uint8Arrays
        self.uint16Arrays = uint16Arrays

        #if canImport(FoundationEssentials) || canImport(Foundation)
        //foundationData = []
        #endif
    }

    func debugDescription<let count: Int, T: StaticRouteResponderProtocol>(for responders: InlineArray<count, Route<T>>) -> String {
        var s = "[]"
        if !responders.isEmpty {
            var values = [String]()
            values.reserveCapacity(responders.count)
            for i in responders.indices {
                values.append(responders[i].debugDescription)
            }
            s = "[" + values.joined(separator: ",\n") + "\n]"
        }
        return s
    }

    public var debugDescription: String {
        """
        CompiledStaticResponderStorage(
            staticStrings: \(debugDescription(for: staticStrings)),
            strings: \(debugDescription(for: strings)),
            stringsWithDateHeader: \(debugDescription(for: stringsWithDateHeader)),
            uint8Arrays: \(debugDescription(for: uint8Arrays)),
            uint16Arrays: \(debugDescription(for: uint16Arrays))
        )
        """
    }

    @inlinable
    public func respond<Router: RouterProtocol & ~Copyable, Socket: SocketProtocol & ~Copyable>(
        router: borrowing Router,
        socket: borrowing Socket,
        startLine: DestinyRoutePathType
    ) async throws -> Bool {
        for i in staticStrings.indices {
            if staticStrings.itemAt(index: i).path == startLine {
                try await router.respondStatically(socket: socket, responder: staticStrings.itemAt(index: i).responder)
                return true
            }
        }
        for i in strings.indices {
            if strings.itemAt(index: i).path == startLine {
                try await router.respondStatically(socket: socket, responder: strings.itemAt(index: i).responder)
                return true
            }
        }
        for i in stringsWithDateHeader.indices {
            //print("stringsWithDateHeader.itemAt(i).path=\(stringsWithDateHeader.itemAt(index: i).path.stringSIMD());areEqual=\(stringsWithDateHeader.itemAt(index: i).path == startLine)")
            if stringsWithDateHeader.itemAt(index: i).path == startLine {
                try await router.respondStatically(socket: socket, responder: stringsWithDateHeader.itemAt(index: i).responder)
                return true
            }
        }
        for i in uint8Arrays.indices {
            if uint8Arrays.itemAt(index: i).path == startLine {
                try await router.respondStatically(socket: socket, responder: uint8Arrays.itemAt(index: i).responder)
                return true
            }
        }
        for i in uint16Arrays.indices {
            if uint16Arrays.itemAt(index: i).path == startLine {
                try await router.respondStatically(socket: socket, responder: uint16Arrays.itemAt(index: i).responder)
                return true
            }
        }
        return false
    }
}

extension CompiledStaticResponderStorage {
    public struct Route<T: StaticRouteResponderProtocol>: CustomDebugStringConvertible, Sendable {
        public let path:DestinyRoutePathType
        public let responder:T

        public init(path: DestinyRoutePathType, responder: T) {
            self.path = path
            self.responder = responder
        }

        public var debugDescription: String {
            """
            Route<\(T.self)>(
                path: \(path.debugDescription),
                responder: \(responder.debugDescription)
            )
            """
        }
    }
}*/

/*
swift-frontend: /home/build-user/llvm-project/llvm/lib/Transforms/Coroutines/CoroFrame.cpp:956: void (anonymous namespace)::FrameTypeBuilder::finish(StructType *): Assertion `Layout->getElementOffset(F.LayoutFieldIndex) == F.Offset' failed.
Please submit a bug report (https://swift.org/contributing/#reporting-bugs) and include the crash backtrace.
Stack dump:
0.      Running pass "require<globals-aa>,function(invalidate<aa>),require<profile-summary>,cgscc(devirt<4>(inline,function-attrs<skip-non-recursive-function-attrs>,function<eager-inv;no-rerun>(sroa<modify-cfg>,early-cse<memssa>,speculative-execution<only-if-divergent-target>,jump-threading,correlated-propagation,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,aggressive-instcombine,tailcallelim,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,reassociate,constraint-elimination,loop-mssa(loop-instsimplify,loop-simplifycfg,licm<no-allowspeculation>,loop-rotate<header-duplication;no-prepare-for-lto>,licm<allowspeculation>,simple-loop-unswitch<no-nontrivial;trivial>),simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,loop(loop-idiom,indvars,simple-loop-unswitch<no-nontrivial;trivial>,loop-deletion,loop-unroll-full),sroa<modify-cfg>,vector-combine,mldst-motion<no-split-footer-bb>,gvn<>,sccp,bdce,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,constraint-elimination,jump-threading,correlated-propagation,adce,memcpyopt,dse,move-auto-init,loop-mssa(licm<allowspeculation>),coro-elide,swift::SwiftARCOptPass,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;hoist-common-insts;sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>),function-attrs,function(require<should-not-run-function-passes>),coro-split)),function(invalidate<should-not-run-function-passes>),cgscc(devirt<4>())" on module "/home/paradigm/Desktop/GitProjects/destiny/.build/x86_64-unknown-linux-gnu/release/DestinyDefaults.build/Application.swift.o"
1.      Running pass "cgscc(devirt<4>(inline,function-attrs<skip-non-recursive-function-attrs>,function<eager-inv;no-rerun>(sroa<modify-cfg>,early-cse<memssa>,speculative-execution<only-if-divergent-target>,jump-threading,correlated-propagation,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,aggressive-instcombine,tailcallelim,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,reassociate,constraint-elimination,loop-mssa(loop-instsimplify,loop-simplifycfg,licm<no-allowspeculation>,loop-rotate<header-duplication;no-prepare-for-lto>,licm<allowspeculation>,simple-loop-unswitch<no-nontrivial;trivial>),simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;no-hoist-common-insts;no-sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,loop(loop-idiom,indvars,simple-loop-unswitch<no-nontrivial;trivial>,loop-deletion,loop-unroll-full),sroa<modify-cfg>,vector-combine,mldst-motion<no-split-footer-bb>,gvn<>,sccp,bdce,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>,constraint-elimination,jump-threading,correlated-propagation,adce,memcpyopt,dse,move-auto-init,loop-mssa(licm<allowspeculation>),coro-elide,swift::SwiftARCOptPass,simplifycfg<bonus-inst-threshold=1;no-forward-switch-cond;switch-range-to-icmp;no-switch-to-lookup;keep-loops;hoist-common-insts;sink-common-insts;speculate-blocks;simplify-cond-branch;no-speculate-unpredictables>,instcombine<max-iterations=1;no-use-loop-info;no-verify-fixpoint>),function-attrs,function(require<should-not-run-function-passes>),coro-split))" on module "/home/paradigm/Desktop/GitProjects/destiny/.build/x86_64-unknown-linux-gnu/release/DestinyDefaults.build/Application.swift.o"
2.      While splitting coroutine @"$s15DestinyDefaults30CompiledStaticResponderStorageV7respond6router6socket9startLineSbqd___qd_0_s6SIMD64Vys5UInt8VGtYaK0A9Blueprint14RouterProtocolRd__AM06SocketP0Rd_0_Ri_d__Ri_d_0_r0_lF"
Rename failed: /home/paradigm/Desktop/GitProjects/destiny/.build/x86_64-unknown-linux-gnu/release/DestinyDefaults.build/HTTPRequestHeaders.swift-9cb8757f.o.tmp -> /home/paradigm/Desktop/GitProjects/destiny/.build/x86_64-unknown-linux-gnu/release/DestinyDefaults.build/HTTPRequestHeaders.swift.o: No such file or directory
*/
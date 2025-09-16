
public struct PerfectHashableItem<T: PerfectHashable>: Sendable {
    public let name:String
    public let simd:T

    public init(
        _ name: String,
        _ simd: T
    ) {
        self.name = name
        self.simd = simd
    }
}

public struct PerfectHashableEntry: Sendable {
    public let name:String
    public let key:UInt64

    public init(name: String, key: UInt64) {
        self.name = name
        self.key = key
    }
}
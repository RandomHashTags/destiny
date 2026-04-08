
#if Compression

public struct CompressorSettings: Sendable {
    public package(set) var contentTypePrefixWhitelist:String?
    public package(set) var contentTypePrefixBlacklist:String?
    public package(set) var contentTypeWhitelist:Set<String>
    public package(set) var contentTypeBlacklist:Set<String>

    public init(
        contentTypePrefixWhitelist: String? = nil,
        contentTypeWhitelist: Set<String> = [],
        contentTypePrefixBlacklist: String? = nil,
        contentTypeBlacklist: Set<String> = []
    ) {
        self.contentTypePrefixWhitelist = contentTypePrefixWhitelist
        self.contentTypeWhitelist = contentTypeWhitelist
        self.contentTypePrefixBlacklist = contentTypePrefixBlacklist
        self.contentTypeBlacklist = contentTypeBlacklist
    }
}

#endif

#if MediaTypes

import MediaTypes

// MARK: CustomDebugStringConvertible
extension MediaType: @retroactive CustomDebugStringConvertible {
    public var debugDescription: String {
        return "MediaType(type: \"\(type)\", subType: \"\(subType)\")"
    }
}

#endif
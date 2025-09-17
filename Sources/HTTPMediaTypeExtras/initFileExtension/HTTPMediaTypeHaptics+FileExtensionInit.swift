
import HTTPMediaTypes

extension HTTPMediaTypeHaptics {
    #if Inlinable
    @inlinable
    #endif
    public init?(fileExtension: some StringProtocol) {
        switch fileExtension {
        default: return nil
        }
    }
}
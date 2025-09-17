
import HTTPMediaTypes

extension HTTPMediaTypeMultipart {
    #if Inlinable
    @inlinable
    #endif
    public init?(fileExtension: some StringProtocol) {
        switch fileExtension {
        default: return nil
        }
    }
}
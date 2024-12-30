//
//  HTTPMediaTypes.swift
//
//
//  Created by Evan Anderson on 12/30/24.
//

// MARK: HTTPMediaTypes
/// All recognized media types by the IANA (https://www.iana.org/assignments/media-types/media-types.xhtml), with additional media types.
/// 
/// Additional Media Types
/// - xGoogleProtobuf & xProtobuf: Protocol Buffers (https://protobuf.dev/)
public enum HTTPMediaTypes {
    public static func parse(_ string: String) -> (any HTTPMediaTypeProtocol)? {
        if let media:Application = Application(rawValue: string) {
            return media
        }
        if let media:Font = Font(rawValue: string) {
            return media
        }
        if let media:Haptics = Haptics(rawValue: string) {
            return media
        }
        if let media:Image = Image(rawValue: string) {
            return media
        }
        if let media:Message = Message(rawValue: string) {
            return media
        }
        if let media:Model = Model(rawValue: string) {
            return media
        }
        if let media:Multipart = Multipart(rawValue: string) {
            return media
        }
        if let media:Text = Text(rawValue: string) {
            return media
        }
        if let media:Video = Video(rawValue: string) {
            return media
        }
        return nil
    }

    public static func parse(_ string: String) -> HTTPMediaType? {
        if let media:Application = Application(rawValue: string) {
            return media.structure
        }
        if let media:Font = Font(rawValue: string) {
            return media.structure
        }
        if let media:Haptics = Haptics(rawValue: string) {
            return media.structure
        }
        if let media:Image = Image(rawValue: string) {
            return media.structure
        }
        if let media:Message = Message(rawValue: string) {
            return media.structure
        }
        if let media:Model = Model(rawValue: string) {
            return media.structure
        }
        if let media:Multipart = Multipart(rawValue: string) {
            return media.structure
        }
        if let media:Text = Text(rawValue: string) {
            return media.structure
        }
        if let media:Video = Video(rawValue: string) {
            return media.structure
        }
        return nil
    }
}

// MARK: HTTPMediaTypeProtocol
public protocol HTTPMediaTypeProtocol : CustomDebugStringConvertible, Hashable, Sendable {
    /// The string suitable as an HTTP header field value.
    var httpValue : String { get }

    var structure : HTTPMediaType { get }
}
public extension HTTPMediaTypeProtocol where Self: RawRepresentable, RawValue == String {
    var structure : HTTPMediaType {
        HTTPMediaType(debugDescription: debugDescription, httpValue: httpValue)
    }
}

// MARK: HTTPMediaType
public struct HTTPMediaType : HTTPMediaTypeProtocol {
    public let debugDescription:String
    public let httpValue:String

    public var structure : HTTPMediaType { self }

    public init(debugDescription: String, httpValue: String) {
        self.debugDescription = debugDescription
        self.httpValue = httpValue
    }
}
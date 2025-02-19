//
//  HTTPMediaTypes+Audio.swift
//
//
//  Created by Evan Anderson on 12/30/24.
//

extension HTTPMediaTypes {
    #HTTPFieldContentType(
        category: "audio",
        values: [
            "aac" : .init("", fileExtensions: ["aac"]),

            "mp4" : .init("", fileExtensions: ["mp4"]),
            "mpeg" : .init("", fileExtensions: ["mpeg"]),

            "ogg" : .init("", fileExtensions: ["ogg"])
        ]
    )
}
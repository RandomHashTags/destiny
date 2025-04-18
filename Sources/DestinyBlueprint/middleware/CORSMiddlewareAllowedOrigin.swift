//
//  CORSMiddlewareAllowedOrigin.swift
//
//
//  Created by Evan Anderson on 12/29/24.
//

public enum CORSMiddlewareAllowedOrigin : Sendable {
    case all
    case any(Set<String>)
    case custom(String)
    case none
    case originBased
}
//
//  DestinyTests.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Testing

import HTTPTypes

import Destiny
import Utilities

struct DestinyTests {
    @Test func example() {
        let router:Router = #router(
            version: "HTTP/2.0",
            middleware: [
                Middleware(appliesToMethods: [.get], appliesToContentTypes: [.html], appliesHeaders: ["Are-You-My-Brother":"yes"])
            ],
            Route(
                method: .get,
                path: "test",
                status: .ok,
                contentType: .html,
                charset: "UTF-8",
                staticResult: .string("<!DOCTYPE html><html>This outcome was inevitable; 'twas your destiny</html>"),
                dynamicResult: nil
            )
        )
    }
}
//
//  Benchmarks.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

import Benchmark
import Utilities

import AsyncHTTPClient

import TestDestiny
import TestHummingbird
import TestVapor

let benchmarks = {
    Benchmark.defaultConfiguration = .init(metrics: .all)

    let libraries:[String:Int] = [
        "Destiny" : 8080,
        "Hummingbird" : 8081,
        "Vapor" : 8082
    ]
    for (library, port) in libraries {
        let request:HTTPClientRequest = HTTPClientRequest(url: "http://192.168.1.96:\(port)/test")
        Benchmark(library) {
            for _ in $0.scaledIterations {
                blackHole(try await HTTPClient.shared.execute(request, timeout: .milliseconds(100)))
            }
        }
    }
}
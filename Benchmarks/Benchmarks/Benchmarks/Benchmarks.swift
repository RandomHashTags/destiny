//
//  Benchmarks.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

import Benchmark
import Utilities

import TestDestiny
import TestHummingbird
import TestVapor

let benchmarks = {
    Benchmark.defaultConfiguration = .init(metrics: .all)

    let libraries:[String:UInt16] = [
        "Destiny" : 8080,
        //"Hummingbird" : 8081,
        //"Vapor" : 8082
    ]
    /*
    for (library, port) in libraries {
        //let request:HTTPClientRequest = HTTPClientRequest(url: "http://192.168.1.96:\(port)/test")
        Benchmark(library) {
            for _ in $0.scaledIterations {
                blackHole(make_request(port: port))
            }
        }
    }*/
}
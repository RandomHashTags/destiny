//
//  Benchmarks.swift
//
//
//  Created by Evan Anderson on 10/18/24.
//

import Benchmark
import Destiny
import Utilities

import HTTPTypes

import TestDestiny
import TestHummingbird
import TestVapor

let benchmarks = {
    Benchmark.defaultConfiguration = .init(metrics: .all)

    /*Benchmark("HTTPFieldName") {
        for _ in $0.scaledIterations {
            blackHole(HTTPField.Name.contentType.rawNameString)
        }
    }*/

    Benchmark("HTTPRequestHeader") {
        for _ in $0.scaledIterations {
            blackHole(HTTPRequestHeader.contentType.rawNameString)
        }
    }

    /*let libraries:[String:UInt16] = [
        "Destiny" : 8080,
        //"Hummingbird" : 8081,
        //"Vapor" : 8082
    ]
    for (library, port) in libraries {
        //let request:HTTPClientRequest = HTTPClientRequest(url: "http://192.168.1.96:\(port)/test")
        Benchmark(library) {
            for _ in $0.scaledIterations {
                blackHole(make_request(port: port))
            }
        }
    }*/
    /*Benchmark("SIMD8<UInt8>") {
        for _ in $0.scaledIterations {
            blackHole(stackString())
        }
    }
    Benchmark("StaticString") {
        for _ in $0.scaledIterations {
            blackHole(StaticString("HlloWRLD"))
        }
    }
    Benchmark("String") {
        for _ in $0.scaledIterations {
            blackHole(string())
        }
    }
    func stackString() -> SIMD8<UInt8> {
        return SIMD8<UInt8>(buffer: (
            Int8(Character("H").asciiValue!),
            Int8(Character("l").asciiValue!),
            Int8(Character("l").asciiValue!),
            Int8(Character("o").asciiValue!),
            Int8(Character("W").asciiValue!),
            Int8(Character("R").asciiValue!),
            Int8(Character("L").asciiValue!),
            Int8(Character("D").asciiValue!)
        ))
    }
    func string() -> String {
        var string:String = "Hllo"
        string += "WRLD"
        return string
    }*/
}
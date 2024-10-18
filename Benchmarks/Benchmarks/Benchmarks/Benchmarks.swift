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
}
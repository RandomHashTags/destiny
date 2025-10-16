#!/bin/bash
function bench_destiny {
    for ((i = 0; i < 3; i++)); do k6 run benchmarkDestiny.js >> results_destiny.txt; done;
}
function bench_hummingbird {
    for ((i = 0; i < 3; i++)); do k6 run benchmarkHummingbird.js >> results_hummingbird.txt; done;
}
function bench_vapor {
    for ((i = 0; i < 3; i++)); do k6 run benchmarkVapor.js >> results_vapor.txt; done;
}
swiftly run swift build -c release
swiftly run swift run -c release &
echo "Waiting 1 minute to make sure the servers are booted..." \
&& sleep 1m \
&& echo "Benchmarking Destiny..." \
&& bench_destiny \
&& echo "Benchmarking Hummingbird..." \
&& bench_hummingbird \
&& echo "Benchmarking Vapor..." \
&& bench_vapor \
&& echo "Benchmarking complete"
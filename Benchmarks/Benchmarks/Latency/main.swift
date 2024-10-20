
import Foundation

let libraries:[String:UInt16] = [
    "Destiny" : 8080,
    //"Hummingbird" : 8081,
    //"Vapor" : 8082
]

let clock:ContinuousClock = ContinuousClock()
for (library, port) in libraries.shuffled() {
    var request:URLRequest = URLRequest(url: URL(string: "http://192.168.1.96:\(port)/test")!)
    request.httpMethod = "GET"
    request.timeoutInterval = 60
    request.addValue("text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7", forHTTPHeaderField: "Accept")
    request.addValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
    request.addValue("max-age=0", forHTTPHeaderField: "Cache-Control")
    request.addValue("http://192.168.1.96:\(port)", forHTTPHeaderField: "Host")
    request.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
    request.addValue("keep-alive", forHTTPHeaderField: "Connection")
    request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
    let amount:Int = 5_000
    var latencies:[ContinuousClock.Duration] = []
    latencies.reserveCapacity(amount)
    try await withThrowingTaskGroup(of: ContinuousClock.Duration.self) { group in
        for _ in 0..<amount {
            group.addTask {
                let now:ContinuousClock.Instant = clock.now
                let (async_bytes, response) = try await URLSession.shared.bytes(for: request)
                let _ = try await async_bytes.allSatisfy({ _ in true })
                return clock.now - now
            }
        }
        for try await latency in group {
            latencies.append(latency)
        }
    }
    latencies = latencies.sorted(by: { $0 < $1 })
    print(library + ": took \(latencies[0]) min; \(latencies[amount-1]) max; \(latencies[(amount-1)/2]) median")
}

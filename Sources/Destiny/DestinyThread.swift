//
//  DestinyThread.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Foundation
import Logging
import DestinyUtilities

final class DestinyThread : Thread, DestinyClientAcceptor {
    var connections:Set<Int32> = Set(minimumCapacity: 50)

    let serverFD:Int32, threadID:Int
    let static_responses:[String:RouteResponseProtocol]
    let not_found_response:StaticString
    let logger:Logger
    init(
        serverFD: Int32,
        threadID: Int,
        static_responses: [String:RouteResponseProtocol],
        not_found_response: StaticString
    ) {
        self.serverFD = serverFD
        self.threadID = threadID
        self.static_responses = static_responses
        self.not_found_response = not_found_response
        logger = Logger(label: "destiny.thread.clientAcceptor\(threadID)")
        super.init()
    }

    func accept(client: Int32) async {
        do {
            try await Server.process_client(client: client, static_responses: static_responses, not_found_response: not_found_response, acceptor: self)
        } catch {
            logger.error(Logger.Message.init(stringLiteral: "\(error)"))
        }
    }

    override func cancel() {
        for client in connections {
            //connection.cancel()
            unistd.close(client)
        }
        connections.removeAll(keepingCapacity: true)
        super.cancel()
    }
}
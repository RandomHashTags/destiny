
import Foundation

protocol NetworkingLibrary {
}

/*
@inlinable
public func make_request(port: UInt16) {
    let socket:Int32 = socket(AF_INET6, SOCK_STREAM, 0)
    var server_addr:sockaddr_in = sockaddr_in()
    server_addr.sin_family = sa_family_t(AF_INET6)
    server_addr.sin_port = port.bigEndian
    server_addr.sin_addr.s_addr = inet_addr("192.168.1.96")

    withUnsafePointer(to: &server_addr, { socket_p in
        let socket_in = UnsafeRawPointer(socket_p).assumingMemoryBound(to: sockaddr.self)
        let connection = connect(socket, socket_in, socklen_t(MemoryLayout<sockaddr_in>.size))
        if connection == 0 {
            var request:String = "GET /test HTTP/1.1\r\n"
            request.withUTF8 { p in
                send(socket, p.baseAddress!, p.count, 0)
            }
            var response:UnsafeMutableRawPointer = .allocate(byteCount: 1024, alignment: MemoryLayout<UInt8>.alignment)
            let read:Int = recv(socket, &response, 1024, 0)
            response.deallocate()
        }
        close(socket)
    })
}*/

#if Epoll

/// An `Error` that indicates failure when handling an epoll operation.
public enum EpollError: DestinyErrorProtocol {
    case epollCreateFailed(errno: Int32)
    case epollPipeFailed(errno: Int32)
    case epollCtlFailed(errno: Int32)
    case waitFailed(errno: Int32)

    case errno(Int32)
    case custom(String)
}

#endif
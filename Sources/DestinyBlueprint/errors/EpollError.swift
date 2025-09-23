
#if Epoll

/// An `Error` that indicates failure when handling an epoll operation.
public enum EpollError: DestinyErrorProtocol {
    case epollCreateFailed(errno: Int32)
    case epollCreateFailed(reason: String)

    case epollPipeFailed(errno: Int32)
    case epollPipeFailed(reason: String)

    case epollCtlFailed(errno: Int32)
    case epollCtlFailed(reason: String)

    case waitFailed(errno: Int32)
    case waitFailed(reason: String)

    case custom(errno: Int32)
    case custom(reason: String)
}

#endif
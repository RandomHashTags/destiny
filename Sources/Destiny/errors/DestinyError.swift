
/// Default errors that can be thrown when using Destiny.
public enum DestinyError: Sendable {

    #if Epoll
    case epollCreateFailed(Int32)
    case epollPipeFailed(Int32)
    case epollCtlFailed(Int32)
    case epollWaitFailed(Int32)
    case epollNegativeLoadedClients
    #endif

    #if HTTPCookie
    case httpCookieIllegalCharacter(Character)
    #endif

    case serverSocketCreationFailed(Int32)
    case serverBindFailed(Int32)
    case serverListenFailed(Int32)

    case socketAcceptFailed(Int32)
    case socketWriteFailed(Int32)
    case socketReadZero
    case socketReadSingleByteFailed(Int32)
    case socketReadBufferFailed(Int32)
    case socketInvalidStatus(Int32)
    case socketCloseFailure(Int32)
    case socketMalformedRequest(Int32)
    case socketBufferWriteError

    case httpMessageError(Int32)
    case middlewareError(Int32)
    case responderError(Int32)
    case routerError(Int32)
    case serviceError(Int32)
    case socketError(Int32)

    case errno(Int32)
    case custom(String)
}


extension DestinyError: Error {}
import Foundation
import Combine
import Starscream

// MARK: - WebsocketServiceInterface
protocol WebsocketServiceInterface {
    var dataPublisher: Published<Data>.Publisher { get }
    var connectionStatusPublisher: CurrentValueSubject<ConnectionStatus, Never> { get }
    var websocketErrorSubject: PassthroughSubject<Error, Never> { get }
    func connect()
    func disconnect()
    func setWebsocketUrl(urlString: String, completion: ((Result<String, Error>) -> Void)?)
}

final class WebsocketService: WebsocketServiceInterface {

    @Published private var streamData: Data = .init()
    var connectionStatusPublisher: CurrentValueSubject<ConnectionStatus, Never> = .init(.disconnected)
    var dataPublisher: Published<Data>.Publisher { $streamData }
    var websocketErrorSubject: PassthroughSubject<Error, Never> = .init()
    var isConnected: CurrentValueSubject<Bool, Never> = .init(false)
    // make internal/public to user the specify chosen url if you are not lazy..
    private lazy var websocket: WebSocket = {
        let socket = WebSocket(request: WebsocketEndPoint.webcam.urlRequest)
        socket.delegate = self
        return socket
    }()
}
// MARK: - Method
extension WebsocketService {
    func connect() {
        websocket.connect()
        handleConnectionStatus()
    }
    func disconnect() {
        websocket.forceDisconnect()
    }
    func setWebsocketUrl(urlString: String, completion: ((Result<String, Error>) -> Void)? = nil) {
            // urlcomponents is a thing right? dance
        guard let url: URL = .init(string: urlString),
                urlString.contains("ws://") || urlString.contains("http://") else {
            completion?(.failure(WebsocketServiceErrors.invalidUrl))
            return
        }
        websocket.request = .init(url: url)
        completion?(.success(urlString))
    }
}

extension WebsocketService: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected:
            connectionStatusPublisher.send(.connected)

        case .cancelled:
            connectionStatusPublisher.send(.cancelled)

        case .disconnected:
            connectionStatusPublisher.send(.disconnected)

        case .binary(let data):
            streamData = data

        case .error(let error):
            connectionStatusPublisher.send(.disconnected)
            if let error = error {
                websocketErrorSubject.send(error)
            }
//            debugPrint(error)

        default:
            connectionStatusPublisher.send(.disconnected)
        }
    }
}
// MARK: - Simple Error Model
extension WebsocketService {
    private enum WebsocketServiceErrors: LocalizedError {
        case invalidUrl

        var errorDescription: String? {
            switch self {
            case .invalidUrl:
                return "Url is Corrupted"
            }
        }
    }
}
// MARK: - Helper
extension WebsocketService {
    private func handleConnectionStatus() {
        if connectionStatusPublisher.value != .connected {
            connectionStatusPublisher.send(.processsing)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if self.connectionStatusPublisher.value == .processsing {
                    self.connectionStatusPublisher.send(.checkServer)
                }
            }
        }
    }
}

// MARK: - Extension WebsocketServiceInterface
extension WebsocketServiceInterface {
    func setWebsocketUrl(urlString: String) {
        setWebsocketUrl(urlString: urlString, completion: nil)
    }
}

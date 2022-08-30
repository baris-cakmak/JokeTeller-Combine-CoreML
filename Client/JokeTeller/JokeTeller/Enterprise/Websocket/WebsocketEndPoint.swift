import Foundation

enum WebsocketEndPoint: URLRequestable {
    case webcam
}
extension WebsocketEndPoint {
    var baseURL: URL {
        .string("ws://x.x.x.x:9997")
    }
    var path: String {
        switch self {
        case .webcam:
            return ""
        }
    }
}

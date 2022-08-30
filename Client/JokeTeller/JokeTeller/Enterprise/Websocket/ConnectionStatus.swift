import UIKit

enum ConnectionStatus: String {
    case connected
    case disconnected
    case cancelled
    case processsing
    case checkServer

    var color: UIColor {
        switch self {
        case .connected:
            return .green

        case .cancelled, .checkServer:
            return .red

        case .disconnected:
            return .orange

        case .processsing:
            return .blue
        }
    }
    var titleCased: String {
        self.rawValue.titleCased()
    }

}

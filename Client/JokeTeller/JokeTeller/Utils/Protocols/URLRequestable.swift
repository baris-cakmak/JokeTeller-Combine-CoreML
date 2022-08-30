import Foundation

protocol URLRequestable {
    var baseURL: URL { get }
    var path: String { get }
    var urlRequest: URLRequest { get }
}
// MARK: - Extension
extension URLRequestable {
    var urlRequest: URLRequest {
        .init(url: baseURL.appendingPathComponent(path, isDirectory: false))
    }
}

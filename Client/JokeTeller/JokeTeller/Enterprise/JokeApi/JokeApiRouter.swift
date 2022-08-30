import Alamofire
import Foundation

enum JokeApiRouter {
case search(keyword: String)
}
extension JokeApiRouter: URLRequestConvertible {
    var baseURL: URL {
        .string("https://humor-jokes-and-memes.p.rapidapi.com/jokes")
    }
    var method: HTTPMethod {
        switch self {
        case .search:
            return .get
        }
    }
    var path: String {
        switch self {
        case .search:
            return "search"
        }
    }
    var headers: HTTPHeaders {
        .init([
            "X-RapidAPI-Key": "bdd88978camsha78e3971a22f6e8p1b7ac2jsnaa49fbdf712c",
            "X-RapidAPI-Host": "humor-jokes-and-memes.p.rapidapi.com"
        ])
    }
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.method = method
        request.headers = headers
        switch self {
        case .search(keyword: let keyword):
            let params = ["keywords": keyword]
            request = try URLEncoding.default.encode(request, with: params)
        }
        return request
    }
}

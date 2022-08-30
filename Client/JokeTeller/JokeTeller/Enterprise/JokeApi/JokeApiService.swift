import Foundation
import Combine
import Alamofire

protocol JokeApiServiceInterface {
    func searchJoke(
        keyword: String,
        completion: @escaping (AnyPublisher<Result<JokeResponseModel, AFError>, Never>) -> Void
    )
}

final class JokeApiService: JokeApiServiceInterface {
    func searchJoke(
        keyword: String,
        completion: @escaping (AnyPublisher<Result<JokeResponseModel, AFError>, Never>) -> Void
    ) {
        request(requestType: .search(keyword: keyword), completion: completion)
    }
}

extension JokeApiService {
    func request<T: Decodable>(
        requestType: JokeApiRouter,
        completion: (AnyPublisher<Result<T, AFError>, Never>) -> Void
    ) {
        let request = AF.request(requestType).publishDecodable(type: T.self)
        completion(request.result())
    }
}

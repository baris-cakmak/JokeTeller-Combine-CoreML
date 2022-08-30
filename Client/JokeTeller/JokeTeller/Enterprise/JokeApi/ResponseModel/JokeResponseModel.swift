import Foundation

// MARK: - JokeResponseModel
struct JokeResponseModel: Decodable {
    let jokes: [Joke]
}
// MARK: - Joke
struct Joke: Decodable {
    let id: Int
    let joke: String
}

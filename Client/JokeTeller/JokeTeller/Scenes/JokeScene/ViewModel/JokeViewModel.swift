import Foundation
import Combine

protocol JokeViewModelInterface {
    var jokeTextSubject: PassthroughSubject<String, Never> { get }
    var imageDataSubject: CurrentValueSubject<Data, Never> { get }
    func viewDidLoad()
}

final class JokeViewModel: JokeViewModelInterface {
    // MARK: - Properties
    var jokeTextSubject: PassthroughSubject<String, Never> = .init()
    var imageDataSubject: CurrentValueSubject<Data, Never> = .init(.init())
    private var jokeDetailModel: JokeDetailModel
    // MARK: - Lifecycle
    init(jokeDetailModel: JokeDetailModel) {
        self.jokeDetailModel = jokeDetailModel
    }
}
// MARK: - Method
extension JokeViewModel {
    func viewDidLoad() {
        jokeTextSubject.send(jokeDetailModel.jokeModel.joke)
        imageDataSubject.send(jokeDetailModel.imageData)
    }
}

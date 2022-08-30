import UIKit

enum JokeBuilder {
    static func createModule(joke: JokeDetailModel) -> UIViewController {
        let viewController = JokeViewController.instantiate(with: .jokeStoryboard)
        let viewModel = JokeViewModel(jokeDetailModel: joke)
        viewController.viewModel = viewModel
        return viewController
    }
}

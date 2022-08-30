import UIKit

enum HomeBuilder {
    static func createModule(
        coreMLModel: VNCoreMLModelReturnable?
    ) -> UIViewController {
        let viewController = HomeViewController.instantiate(with: .main)
        let viewModel = HomeViewModel(
            websocketService: WebsocketService(),
            coreMLService: CoreMLService(),
            coreMLModel: coreMLModel ?? CoreMLModels.squeezeNet,
            jokeApiService: JokeApiService()
        )
        viewController.viewModel = viewModel
        return viewController
    }
}

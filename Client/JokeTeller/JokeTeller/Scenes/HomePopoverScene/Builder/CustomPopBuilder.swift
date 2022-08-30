import UIKit

enum CustomPopBuilder {
    static func createModule(using navigationController: UINavigationController?) -> UIViewController {
        let viewController = CustomPopViewController()
        let viewModel = CustomPopViewModel()
        viewController.viewModel = viewModel
        return viewController
    }
}

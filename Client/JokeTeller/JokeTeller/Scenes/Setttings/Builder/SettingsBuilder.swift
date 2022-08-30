import Foundation
import UIKit

enum SettingsBuilder {
    static func createModule() -> UIViewController {
        let viewController = SettingsViewController()
        let viewModel = SettingsViewModel()
        viewController.viewModel = viewModel
        return viewController
    }
}

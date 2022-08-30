import UIKit

protocol JokeTransitionable: AnyObject {
    var interactionController: JokeAnimatorController? { get set }
    func setInteractionController()
}
// MARK: - Extension
extension JokeTransitionable where Self: UIViewController {
    func setInteractionController() {
        interactionController = .init(viewController: self)
    }
}

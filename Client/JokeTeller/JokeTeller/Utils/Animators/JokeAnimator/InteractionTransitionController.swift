import UIKit

final class JokeAnimatorController: NSObject {
    // MARK: - Properties
    private var interactiveTransition: JokeInteractiveTransitioning
    private var animator: JokeAnimator
    weak private var viewController: UIViewController?
    weak var fromDelegate: JokeAnimatorDelegate?
    weak var toDelegate: JokeAnimatorDelegate?
    // MARK: - Init
    init(
        viewController: UIViewController
    ) {
        self.animator = .init()
        self.interactiveTransition = .init()
        self.interactiveTransition.jokeAnimator = animator
        self.interactiveTransition.viewController = viewController
        self.viewController = viewController
        // adding pangesture
        super.init()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        panGesture.delegate = self
        viewController.view.addGestureRecognizer(panGesture)
    }
}
// MARK: - UIGestureRecognizer Delegate
extension JokeAnimatorController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        var shouldBegin = false
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGesture.velocity(in: viewController?.view)
            shouldBegin = velocity.y < .zero ? false : true
        }
        return shouldBegin
    }
}
// MARK: - Action
extension JokeAnimatorController {
    @objc func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
        interactiveTransition.handlePanGesture(panGesture)
        switch panGesture.state {
        case .began:
            interactiveTransition.inProgress = true
            viewController?.navigationController?.popViewController(animated: true)

        case .ended:
            interactiveTransition.inProgress = false

        default:
            break
        }
    }
}
// MARK: - UINavigationController Delegate
extension JokeAnimatorController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            animator.isPresenting = true
            animator.fromDelegate = fromDelegate
            animator.toDelegate = toDelegate
            return animator

        case .pop:
            animator.isPresenting = false
            animator.fromDelegate = toDelegate
            animator.toDelegate = fromDelegate
            return animator

        default:
            return nil
        }
    }
    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        guard interactiveTransition.inProgress else {
            return nil
        }
        return interactiveTransition
    }
}

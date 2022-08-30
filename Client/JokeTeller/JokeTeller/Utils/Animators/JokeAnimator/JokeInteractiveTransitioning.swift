import UIKit

final class JokeInteractiveTransitioning: NSObject {
    // MARK: - Properties
    var inProgress = false
    weak var jokeAnimator: JokeAnimator?
    weak var viewController: UIViewController?
    private weak var transitionContext: UIViewControllerContextTransitioning?
    private var snapshotView: UIView?
}
// MARK: - Method
extension JokeInteractiveTransitioning {
    func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
        guard let view = viewController?.view,
              let transitionContext = transitionContext,
              let jokeAnimator = jokeAnimator,
              let fromImageFrame = jokeAnimator.fromDelegate?.referenceFrame(jokeAnimator),
              let toImageFrame = jokeAnimator.toDelegate?.referenceFrame(jokeAnimator),
              let toView = transitionContext.view(forKey: .to),
              let snapshotView = snapshotView else {
            return
        }
        let translation = panGesture.translation(in: view)
        let velocity = panGesture.velocity(in: view).y
        let percentage = translation.y / (view.bounds.height / 2)
        let verticalDelta: CGFloat = translation.y < .zero ? .zero : translation.y
        let alphaToBeAnimated: CGFloat = calculateAlpha(viewForHeightRatio: view, verticalChange: verticalDelta)
        let imageScale: CGFloat = calculateScale(viewForHeightRatio: view, verticalChange: verticalDelta)
        let anchorPointOfFromImageFrame: CGPoint = .init(x: fromImageFrame.midX, y: fromImageFrame.midY)
        let newCenter: CGPoint = .init(
            x: (anchorPointOfFromImageFrame.x + translation.x),
            y: (anchorPointOfFromImageFrame.y + (translation.y - snapshotView.frame.height * (1 - imageScale) / JokeInteractivePresentationConstants.scaleRatioRespectToHeight))
        )
        jokeAnimator.fromDelegate?.animationWillStart()
        jokeAnimator.toDelegate?.animationWillStart()
        toView.alpha = alphaToBeAnimated
        snapshotView.transform = .init(scaleX: imageScale, y: imageScale)
        snapshotView.center = newCenter
        transitionContext.updateInteractiveTransition(percentage)
        if panGesture.state == .ended {
            handleFinishedStateGesture(
                percentage: percentage,
                velocity: velocity,
                snapshotView: snapshotView,
                jokeAnimator: jokeAnimator,
                fromImageFrame: fromImageFrame,
                toImageFrame: toImageFrame
            )
        }
    }
}
// MARK: - Helper
extension JokeInteractiveTransitioning {
    private func calculateAlpha(viewForHeightRatio: UIView, verticalChange: CGFloat) -> CGFloat {
        let maximumRatio = viewForHeightRatio.bounds.height / 4
        let changeInRespectToMaximumRatio = max(
            min(abs(verticalChange) / maximumRatio, Constants.full),
            JokeInteractivePresentationConstants.minimumToViewAlpha
        )
        return changeInRespectToMaximumRatio
    }
    private func calculateScale(viewForHeightRatio: UIView, verticalChange: CGFloat) -> CGFloat {
        let startingScaleRatio: CGFloat = Constants.full
        let finalScale: CGFloat = Constants.half
        let maximumRatio = viewForHeightRatio.bounds.height / JokeInteractivePresentationConstants.scaleRatioRespectToHeight
        let changeInRespectToMaximumRatio = min(abs(verticalChange) / maximumRatio, Constants.full)
        return Constants.full - abs(finalScale - startingScaleRatio) * changeInRespectToMaximumRatio
    }
    private func handleFinishedStateGesture(
        percentage: CGFloat,
        velocity: CGFloat,
        snapshotView: UIView,
        jokeAnimator: JokeAnimator,
        fromImageFrame: CGRect,
        toImageFrame: CGRect
    ) {
        guard
            let transitionContext = transitionContext,
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
        else {
            return
        }
        // Cancel the transition
        if percentage < JokeInteractivePresentationConstants.percentageLimitForTransition &&
            velocity < JokeInteractivePresentationConstants.velocityLimit {
            UIView.animate(
                withDuration: JokeInteractivePresentationConstants.cancelTransitionDuration,
                animations: {
                    snapshotView.frame = fromImageFrame
                },
                completion: { _ in
                    fromView.isHidden = false
                    snapshotView.removeFromSuperview()
                    transitionContext.cancelInteractiveTransition()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                    jokeAnimator.fromDelegate?.animationDidFinish()
                    jokeAnimator.toDelegate?.animationDidFinish()
                }
            )
        } else {
            // Finish the transition
            UIView.animate(
                withDuration: JokeInteractivePresentationConstants.finishTransitionDuration,
                animations: {
                    toView.alpha = Constants.full
                    snapshotView.frame = toImageFrame
                },
                completion: { _ in
                    snapshotView.removeFromSuperview()
                    transitionContext.finishInteractiveTransition()
                    self.viewController = nil
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                    jokeAnimator.toDelegate?.animationDidFinish()
                    jokeAnimator.fromDelegate?.animationDidFinish()
                }
            )
        }
    }
}
// MARK: - UIViewControllerInteractiveTransitioning
extension JokeInteractiveTransitioning: UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        guard
            let jokeAnimator = jokeAnimator,
            let toView = transitionContext.view(forKey: .to),
            let fromView = transitionContext.view(forKey: .from),
            let fromImage = jokeAnimator.fromDelegate?.referenceImage(jokeAnimator),
            let fromImageViewFrame = jokeAnimator.fromDelegate?.referenceFrame(jokeAnimator) else {
                return
        }
        self.transitionContext = transitionContext
        let contanierView = transitionContext.containerView
        fromView.isHidden = true
        fromImage.isHidden = false
        toView.alpha = .zero
        contanierView.addSubview(toView)
        if let snapshotView = fromImage.snapshotView(afterScreenUpdates: true) {
            snapshotView.frame = fromImageViewFrame
            contanierView.addSubview(snapshotView)
            self.snapshotView = snapshotView
        }
    }
}
// MARK: - Constants
extension JokeInteractiveTransitioning {
    private enum JokeInteractivePresentationConstants {
        static let cancelTransitionDuration: CGFloat = 0.3
        static let finishTransitionDuration: CGFloat = 0.5
        static let minimumToViewAlpha: CGFloat = 0.1
        static let percentageLimitForTransition: CGFloat = 0.4
        static let velocityLimit: CGFloat = 1000
        static let scaleRatioRespectToHeight: CGFloat = 3
    }
}

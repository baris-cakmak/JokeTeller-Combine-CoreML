import UIKit

protocol JokeAnimatorDelegate: AnyObject {
    func animationWillStart()
    func animationDidFinish()
    func referenceImage(_ animator: JokeAnimator) -> UIImageView
    func referenceFrame(_ animator: JokeAnimator) -> CGRect
}

final class JokeAnimator: NSObject {
    weak var fromDelegate: JokeAnimatorDelegate?
    weak var toDelegate: JokeAnimatorDelegate?
    var isPresenting = true
}
// MARK: - Animate Presentation
extension JokeAnimator {
    private func animatePresentation(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to),
              let snapshotView = fromDelegate?.referenceImage(self).snapshotView(afterScreenUpdates: true),
              let fromImageViewFrame = fromDelegate?.referenceFrame(self),
              let toDelegate = toDelegate else {
            return
        }
        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        toDelegate.animationWillStart()
        toView.alpha = .zero
        snapshotView.frame = fromImageViewFrame
        containerView.addSubview(toView)
        containerView.addSubview(snapshotView)
        UIView.animate(
            withDuration: duration,
            animations: {
                snapshotView.frame = toDelegate.referenceFrame(self)
                toView.alpha = Constants.full
            },
            completion: { _ in
                toDelegate.animationDidFinish()
                snapshotView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}
// MARK: - Animate Dismissal
extension JokeAnimator {
    private func animateDismissal(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to),
              let snapshotView = fromDelegate?.referenceImage(self).snapshotView(afterScreenUpdates: true),
              let fromImageViewFrame = fromDelegate?.referenceFrame(self),
              let toDelegate = toDelegate else {
            return
        }
        let contanierView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        toDelegate.animationWillStart()
        snapshotView.frame = fromImageViewFrame
        fromView.isHidden = true
        contanierView.addSubview(toView)
        contanierView.addSubview(snapshotView)
        UIView.animateKeyframes(
            withDuration: duration,
            delay: .zero,
            options: .calculationModeLinear,
            animations: {
                UIView.addKeyframe(
                    withRelativeStartTime: .zero,
                    relativeDuration: Constants.half
                ) {
                    toView.alpha = Constants.half
                    snapshotView.frame = toDelegate.referenceFrame(self)
                }
                UIView.addKeyframe(
                    withRelativeStartTime: Constants.half,
                    relativeDuration: Constants.half
                ) {
                    fromView.alpha = .zero
                    toView.alpha = Constants.full
                    snapshotView.transform = .init(scaleX: Constants.full, y: Constants.full)
                }
            },
            completion: { _ in
                toDelegate.animationDidFinish()
                fromView.isHidden = false
                snapshotView.frame = toDelegate.referenceFrame(self)
                snapshotView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}

// MARK: - UIViewControllerAnimatedTransitioning
extension JokeAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        Constants.threeQuarter
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        isPresenting ? animatePresentation(using: transitionContext) : animateDismissal(using: transitionContext)
    }
}

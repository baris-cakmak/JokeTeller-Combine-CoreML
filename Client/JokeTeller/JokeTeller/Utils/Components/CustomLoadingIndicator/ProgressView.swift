import UIKit

final class ProgressView: UIView {
    // MARK: - Properties
    let colors: [UIColor]
    let lineWidth: CGFloat
    let dimmingView: UIView = .init()
    var isAnimating = false {
        didSet {
            isAnimating ? animateStroke() : removeViews()
        }
    }
    var showDimmingBackground = false {
        didSet {
            showDimmingBackground ? addDimming() : dimmingView.removeFromSuperview()
        }
    }
    private lazy var progressShapeLayer: ProgressShapeLayer = {
        // changed
        let shapeLayer = ProgressShapeLayer(strokeColor: colors[0], lineWidth: lineWidth)
        return shapeLayer
    }()
    // MARK: - Init
    init(frame: CGRect, colors: [UIColor], lineWidth: CGFloat) {
        self.colors = colors
        self.lineWidth = lineWidth
        super.init(frame: frame)
    }
    convenience init(colors: [UIColor], lineWidth: CGFloat) {
        self.init(frame: .zero, colors: colors, lineWidth: lineWidth)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(
            ovalIn: .init(
                x: .zero,
                y: .zero,
                width: bounds.width,
                height: bounds.height
            )
        )
        self.layer.cornerRadius = frame.width / 2
        progressShapeLayer.path = path.cgPath
    }
}
// MARK: - Animations
extension ProgressView {
    private func addDimming() {
        dimmingView.backgroundColor = .black.withAlphaComponent(Constants.threeQuarter)
        if let superview = superview {
            dimmingView.frame = superview.bounds
            superview.insertSubview(dimmingView, belowSubview: self)
        }
    }
    private func animateStroke() {
        let startAnimation: StrokeAnimation = .init(
            type: .start,
            beginTime: ProgressViewConstants.startAnimationBeginTime,
            fromValue: ProgressViewConstants.startAnimationFromValue,
            toValue: ProgressViewConstants.startAnimationToValue,
            duration: ProgressViewConstants.startAnimationDuration
        )
        let endAnimation: StrokeAnimation = .init(
            type: .end,
            fromValue: ProgressViewConstants.endAnimationFromValue,
            toValue: ProgressViewConstants.endAnimationToValue,
            duration: ProgressViewConstants.endAnimationDuration
        )
        let strokeAnimationGroup = CAAnimationGroup()
        strokeAnimationGroup.duration = 1
        strokeAnimationGroup.repeatDuration = .infinity
        strokeAnimationGroup.animations = [startAnimation, endAnimation]
        progressShapeLayer.add(strokeAnimationGroup, forKey: nil)
        let colorAnimation: StrokeColorAnimation = .init(
            colors: colors.map { $0.cgColor },
            duration: strokeAnimationGroup.duration * Double(colors.count)
        )
        progressShapeLayer.add(colorAnimation, forKey: nil)
        layer.addSublayer(progressShapeLayer)
    }
}
// MARK: - Helper
extension ProgressView {
    private func removeViews() {
        removeFromSuperview()
        dimmingView.removeFromSuperview()
    }
}
// MARK: - Constants
extension ProgressView {
    private enum ProgressViewConstants {
        // StartAnimation Constants
        static let startAnimationBeginTime: Double = 0.3
        static let startAnimationFromValue: CGFloat = .zero
        static let startAnimationToValue: CGFloat = 1
        static let startAnimationDuration: Double = 0.7
        // EndAnimation Constants
        static let endAnimationFromValue: CGFloat = .zero
        static let endAnimationToValue: CGFloat = 1
        static let endAnimationDuration: Double = 0.7
    }
}

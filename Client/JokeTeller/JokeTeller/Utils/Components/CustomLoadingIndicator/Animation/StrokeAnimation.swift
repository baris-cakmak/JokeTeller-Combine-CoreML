import UIKit

final class StrokeAnimation: CABasicAnimation {
    enum StrokeType {
        case start
        case end
    }
    override init() {
        super.init()
    }

    init(
        type: StrokeType,
        beginTime: Double = .zero,
        fromValue: CGFloat,
        toValue: CGFloat,
        duration: Double
    ) {
        super.init()
        self.keyPath = type == .start ? StrokeAnimationConstants.startKeyPath : StrokeAnimationConstants.endKeyPath
        self.beginTime = beginTime
        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = duration
        self.timingFunction = .init(name: .easeInEaseOut)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - Constants
extension StrokeAnimation {
    enum StrokeAnimationConstants {
        static let startKeyPath: String = "strokeStart"
        static let endKeyPath: String = "strokeEnd"
    }
}

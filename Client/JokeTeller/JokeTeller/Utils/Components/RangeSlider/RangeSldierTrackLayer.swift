import UIKit

final class RangeSliderTrackLayer: CAGradientLayer {
    weak var rangeSlider: RangeSlider?
    // MARK: - Lifecycle
    override func draw(in ctx: CGContext) {
        guard let rangeSlider = rangeSlider else {
            return
        }
        let lowerValuePosition = rangeSlider.positionForValue(rangeSlider.lowerValue)
        let upperValuePosition = rangeSlider.positionForValue(rangeSlider.upperValue)
        let lowerRect: CGRect = .init(
            x: .zero,
            y: .zero,
            width: lowerValuePosition,
            height: bounds.height
        )
        let upperRect: CGRect = .init(
            x: upperValuePosition,
            y: .zero,
            width: bounds.width - upperValuePosition,
            height: bounds.height
        )
        masksToBounds = true
        cornerRadius = frame.height / 2
        colors = [
            rangeSlider.firstGradientColor.cgColor,
            rangeSlider.secondGradientColor.cgColor
        ]
        startPoint = .init(x: rangeSlider.lowerValue, y: Constants.half)
        endPoint = .init(x: rangeSlider.upperValue, y: Constants.half)
        ctx.setFillColor(rangeSlider.trackTintColor.cgColor)
        ctx.fill([lowerRect, upperRect])
    }
}

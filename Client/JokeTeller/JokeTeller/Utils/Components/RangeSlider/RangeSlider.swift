import UIKit

@IBDesignable
final class RangeSlider: UIControl {
    @IBInspectable
    var minimumValue: CGFloat = .zero {
        didSet {
            updateLayerFrames()
        }
    }
    @IBInspectable
    var maximumValue: CGFloat = 1 {
        didSet {
            updateLayerFrames()
        }
    }
    @IBInspectable
    var lowerValue: CGFloat = 0.2 {
        didSet {
            updateLayerFrames()
        }
    }
    @IBInspectable
    var upperValue: CGFloat = 0.8 {
        didSet {
            updateLayerFrames()
        }
    }
    @IBInspectable
    var firstGradientColor: UIColor = .cyan {
        didSet {
            updateLayerFrames()
        }
    }
    @IBInspectable
    var secondGradientColor: UIColor = .purple {
        didSet {
            updateLayerFrames()
        }
    }
    @IBInspectable
    var thumbImage: UIImage = RangeSlilderConstants.thumbImage {
        didSet {
            lowerThumbImageView.image = thumbImage
            upperThumbImageView.image = thumbImage
            updateLayerFrames()
        }
    }
    @IBInspectable
    var highlightedImage: UIImage = RangeSlilderConstants.highlightedThumbImage {
        didSet {
            lowerThumbImageView.highlightedImage = highlightedImage
            upperThumbImageView.highlightedImage = highlightedImage
            updateLayerFrames()
        }
    }
    private let trackLayer = RangeSliderTrackLayer()
    private let lowerThumbImageView = UIImageView()
    private let upperThumbImageView = UIImageView()
    private var previousLocation = CGPoint()

    @IBInspectable
    var trackTintColor: UIColor = RangeSlilderConstants.trackTintColor {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    override func prepareForInterfaceBuilder() {
        updateLayerFrames()
    }
    // MARK: - Helper
    private func setupUI() {
        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)
        lowerThumbImageView.image = thumbImage
        addSubview(lowerThumbImageView)
        upperThumbImageView.image = thumbImage
        addSubview(upperThumbImageView)
        updateLayerFrames()
    }
}
// MARK: - Action
extension RangeSlider {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        var shouldBegin = false
        if lowerThumbImageView.frame.contains(previousLocation) {
            lowerThumbImageView.isHighlighted = true
        } else if upperThumbImageView.frame.contains(previousLocation) {
            upperThumbImageView.isHighlighted = true
        }
        shouldBegin = lowerThumbImageView.isHighlighted || upperThumbImageView.isHighlighted ? true : false
        return shouldBegin
    }
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        let deltaLocation = location.x - previousLocation.x
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / bounds.width
        previousLocation = location
        if lowerThumbImageView.isHighlighted {
            lowerValue += deltaValue
            lowerValue = boundValue(lowerValue, toLowerValue: minimumValue, toUpperValue: upperValue)
        } else if upperThumbImageView.isHighlighted {
            upperValue += deltaValue
            upperValue = boundValue(upperValue, toLowerValue: lowerValue, toUpperValue: maximumValue)
        }

        updateLayerFrames()
        sendActions(for: .valueChanged)
        return true
    }
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        lowerThumbImageView.isHighlighted = false
        upperThumbImageView.isHighlighted = false
    }
}
// MARK: - Method
extension RangeSlider {
    func positionForValue(_ value: CGFloat) -> CGFloat {
        bounds.width * value
    }
}

// MARK: - Helper
extension RangeSlider {
    private func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        trackLayer.frame = bounds.insetBy(dx: .zero, dy: bounds.height / 3)
        trackLayer.setNeedsDisplay()
        lowerThumbImageView.frame = .init(origin: thumbOriginValue(lowerValue), size: thumbImage.size)
        upperThumbImageView.frame = .init(origin: thumbOriginValue(upperValue), size: thumbImage.size)
        CATransaction.commit()
    }
    private func thumbOriginValue(_ value: CGFloat) -> CGPoint {
        let xPosition = positionForValue(value) - thumbImage.size.width / 2
        let yPosition = (bounds.height - thumbImage.size.height) / 2
        return .init(x: xPosition, y: yPosition)
    }
    private func boundValue(
        _ value: CGFloat,
        toLowerValue lowerValue: CGFloat,
        toUpperValue upperValue: CGFloat
    ) -> CGFloat {
        min(max(value, lowerValue), upperValue)
    }
}
// MARK: - Constant
extension RangeSlider {
    private enum RangeSlilderConstants {
        static let trackTintColor: UIColor = .init(white: 0.7, alpha: 1)
        static let thumbImage: UIImage = .init(systemName: "star.fill") ?? UIImage()
        static let highlightedThumbImage: UIImage = .init(systemName: "star.fill") ?? UIImage()
    }
}

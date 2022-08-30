import UIKit

extension UIButton {
    var titleTextForNormal: String? {
        get {
            title(for: .normal)
        }
        set {
            setTitle(newValue, for: .normal)
        }
    }
}

import UIKit

 @available(iOS 16.0, *)
 extension UISheetPresentationController.Detent {
    class func small() -> UISheetPresentationController.Detent {
        UISheetPresentationController.Detent.custom { _ in
            return 80
        }
    }
 }

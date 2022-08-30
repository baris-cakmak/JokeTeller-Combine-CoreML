import UIKit

extension CIImage {
    static func data(_ someData: Data) -> CIImage {
        guard let ciImage = CIImage(data: someData) else {
            fatalError("noImage Data")
        }
        return ciImage
    }
}

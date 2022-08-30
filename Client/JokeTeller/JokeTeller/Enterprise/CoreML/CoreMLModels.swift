import Foundation
import Vision

protocol VNCoreMLModelReturnable {
    var model: VNCoreMLModel { get }
    func convertMLModelToVNCoreModel(_ mlModel: MLModel) -> VNCoreMLModel
}
extension VNCoreMLModelReturnable {
    func convertMLModelToVNCoreModel(_ mlModel: MLModel) -> VNCoreMLModel {
        guard let model = try? VNCoreMLModel(for: mlModel) else {
            fatalError("VNCoreMLModel not found")
        }
        return model
    }
}

enum CoreMLModels: VNCoreMLModelReturnable, CaseIterable {
    case squeezeNet
    case mobileNet
    case resnet50
    case inceptionv3
    // for fun
    var model: VNCoreMLModel {
        switch self {
        case .squeezeNet:
            return convertMLModelToVNCoreModel(SqueezeNet().model)

        case .mobileNet:
            return convertMLModelToVNCoreModel(MobileNet().model)

        case .resnet50:
            return convertMLModelToVNCoreModel(Resnet50().model)

        case .inceptionv3:
            return convertMLModelToVNCoreModel(Inceptionv3().model)
        }
    }
}

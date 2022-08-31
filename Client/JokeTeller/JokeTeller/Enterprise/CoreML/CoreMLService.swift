import Foundation
import Combine
import Vision
import CoreImage

struct InferenceOutputSetings {
    var minimumConfidence: Double = .zero
    var maximumConfidence: Double = Constants.full
}
protocol CoreMLServiceInterface {
    var inferenceOutputPublisher: Published<[String]>.Publisher { get }
    var requestMLModelSubject: PassthroughSubject<VNCoreMLRequest, Never> { get }
    var inferenceDescriptionSubject: CurrentValueSubject<String?, Never> { get }
    func requestMLModel(
        _ mlModel: VNCoreMLModelReturnable,
        with configurations: InferenceOutputSetings
    ) -> VNCoreMLRequest
    func performRequest(_ request: VNCoreMLRequest, with ciImage: CIImage)
}

final class CoreMLService: CoreMLServiceInterface {
    var inferenceDescriptionSubject: CurrentValueSubject<String?, Never> = .init(nil)
    var requestMLModelSubject: PassthroughSubject<VNCoreMLRequest, Never> = .init()
    @Published var inferenceOutputs: [String] = [""]
    var inferenceOutputPublisher: Published<[String]>.Publisher { $inferenceOutputs }
    func requestMLModel(
        _ mlModel: VNCoreMLModelReturnable,
        with configurations: InferenceOutputSetings
    ) -> VNCoreMLRequest {
        let model = mlModel.model
        let request = VNCoreMLRequest(model: model) { req, _ in
            self.handleCoreMLRequestResult(req.results, with: configurations)
        }
        request.imageCropAndScaleOption = .scaleFill
        requestMLModelSubject.send(request)
        return request
    }
    func performRequest(_ request: VNCoreMLRequest, with ciImage: CIImage) {
        let handler: VNImageRequestHandler = .init(ciImage: ciImage)
        do {
            try handler.perform([request])
        } catch {
            // TODO: - Handle Error
            print(error.localizedDescription)
        }
    }
}
// MARK: - Helper
extension CoreMLService {
    private func handleCoreMLRequestResult(
        _ results: [VNObservation]?,
        with configurations: InferenceOutputSetings
    ) {
        // image classification
        if let unwrappedResults = results as? [VNClassificationObservation] {
            let firstIdentifier = unwrappedResults.prefix(upTo: 1)
                .filter {
                    (configurations.minimumConfidence...configurations.maximumConfidence)
                    .contains(Double($0.confidence))
                }
                .map { observation in
                    observation.identifier.components(separatedBy: ",").first
                }.first
            inferenceOutputs = unwrappedResults.prefix(upTo: 2)
                .filter {
                    (configurations.minimumConfidence...configurations.maximumConfidence)
                    .contains(Double($0.confidence))
                }
                .compactMap {"\($0.confidence.formatted(.percent)) \($0.identifier)"
                }
            if let firstIdentifier = firstIdentifier {
                inferenceDescriptionSubject.send(firstIdentifier)
            }
        }
        // object detection -- cast as different observation...
        // TODO: - Unwrap the result and use boundingBox parameter to draw boxes
    }
}

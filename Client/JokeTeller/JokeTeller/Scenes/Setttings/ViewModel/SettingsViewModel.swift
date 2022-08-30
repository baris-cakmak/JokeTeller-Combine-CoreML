import Foundation
import Combine

enum SettingsSection {
    case main
}
protocol SettingsViewModelInterface {
    func saveCoreMLModel(at indexPath: IndexPath)
    var snapshotSubject: CurrentValueSubject<SettingsSnapshot, Never> { get }
    var coreMLModelSubject: CurrentValueSubject<VNCoreMLModelReturnable, Never> { get }
}
final class SettingsViewModel: SettingsViewModelInterface {
    @Published var coreMLModelSubject: CurrentValueSubject<VNCoreMLModelReturnable, Never> = .init(CoreMLModels.squeezeNet)
    var snapshotSubject: CurrentValueSubject<SettingsSnapshot, Never> {
        var snapshot = SettingsSnapshot()
        snapshot.appendSections([.main])
        let coreModelNames = CoreMLModels.allCases.map { "\($0)" }
        snapshot.appendItems(coreModelNames)
        return .init(snapshot)
    }
}
// MARK: - Method
extension SettingsViewModel {
    func saveCoreMLModel(at indexPath: IndexPath) {
        coreMLModelSubject.send(CoreMLModels.allCases[indexPath.item])
    }
}

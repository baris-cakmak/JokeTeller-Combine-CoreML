import Foundation
import Combine

protocol CustomPopViewModelInterface {
    var popLabelTextSubject: CurrentValueSubject<String, Never> { get set }
    func viewDidLoad()
}
final class CustomPopViewModel: CustomPopViewModelInterface {
    // MARK: - Properties
    var popLabelTextSubject: CurrentValueSubject<String, Never> = .init("Enter your websocket address")
    @Stroge(key: .webscoketUrlString)
    private var storedWebscoket: String?
}
// MARK: - Method
extension CustomPopViewModel {
    func viewDidLoad() {
        guard let storedWebscoket = storedWebscoket else {
            return
        }
        popLabelTextSubject.send("Saved Adress is \(storedWebscoket)")
    }
}

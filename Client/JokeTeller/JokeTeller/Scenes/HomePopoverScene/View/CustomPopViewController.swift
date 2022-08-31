import UIKit
import PLAlert
import Combine

protocol CustomPopViewControllerDelegate: AnyObject {
    func didUserSavedText(_ text: String)
}
final class CustomPopViewController: UIViewController, AlertPresentable {
    // MARK: - Constraints
    // swiftlint: disable implicitly_unwrapped_optional
    var buttonBottomConstraint: NSLayoutConstraint!
    // MARK: - UI Properties
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        [popLabel, popTextField, popButton].forEach { view in
            stackView.addArrangedSubview(view)
        }
        stackView.spacing = 10
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private let popLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter your websocket address"
        label.numberOfLines = .zero
        label.minimumScaleFactor = 0.75
        label.adjustsFontSizeToFitWidth = true
        label.setContentHuggingPriority(.init(rawValue: 249), for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var popButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Save", for: .normal)
        button.addTarget(self, action: #selector(didTapPopButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .heavy)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var popTextField: UITextField = {
        let textField = UITextField()
        textField.leftView = .init(frame: .init(x: 10, y: .zero, width: 15, height: 15))
        textField.leftViewMode = .always
        textField.autocapitalizationType = .none
        textField.font = .systemFont(ofSize: 18, weight: .semibold)
        textField.placeholder = "ws://xxx.x.x.x:xxxx"
        textField.delegate = self
        textField.layer.masksToBounds = false
        textField.backgroundColor = .init(white: 0.9, alpha: 0.9)
        textField.setContentHuggingPriority(.init(rawValue: 250), for: .vertical)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    // MARK: - Properties
    weak var delegate: CustomPopViewControllerDelegate?
    private var cancellabels: Set<AnyCancellable> = .init()
    var viewModel: CustomPopViewModelInterface!
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        viewModel.viewDidLoad()
        registerToViewModel()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // magic number dance
        popTextField.layer.cornerRadius = (popTextField.frame.height / 2) - 5
    }
}
// MARK: - Action
extension CustomPopViewController {
    @objc func didTapPopButtonTapped(button: UIButton) {
        guard let text = popTextField.text, !text.isEmpty else {
            return showAlert(
                type: PLAlertController.self,
                title: "Type Error",
                message: "Text Something",
                buttonText: "Cancel"
            )
        }
        dismiss(animated: true)
        delegate?.didUserSavedText(text)
    }
}
// MARK: - Setup UI
extension CustomPopViewController {
    func setupUI() {
        addBlurEffect()
        addGradientLayer()
        view.addSubview(containerStackView)
    }
}
// MARK: - Setup Layout
extension CustomPopViewController {
    func setupLayout() {
        buttonBottomConstraint = popButton.heightAnchor.constraint(equalToConstant: 50)
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            containerStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            popTextField.heightAnchor.constraint(equalToConstant: 50),
            buttonBottomConstraint
        ])
    }
}
// MARK: - Helper
extension CustomPopViewController {
    private func registerToViewModel() {
        viewModel
            .popLabelTextSubject
            .sink { [weak self] value in
                self?.popLabel.text = value
            }
            .store(in: &cancellabels)
    }
    private func addBlurEffect() {
        let blurEffect: UIBlurEffect = .init(style: .systemThinMaterial)
        let blurEffectView: UIVisualEffectView = .init(effect: blurEffect)
        blurEffectView.frame = view.bounds
        view.addSubview(blurEffectView)
    }
    private func addGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
        gradientLayer.startPoint = .init(x: .zero, y: 1)
        gradientLayer.endPoint = .init(x: 0.5, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: .zero)
    }
}
// MARK: - UITextField Delegate
extension CustomPopViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        buttonBottomConstraint?.isActive = false
        UIView.animate(
            withDuration: 1,
            delay: .zero,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.3
        ) {
            self.popLabel.isHidden = true
            self.buttonBottomConstraint = self.popButton.heightAnchor.constraint(
                greaterThanOrEqualTo: self.view.heightAnchor,
                multiplier: 1 / 3
            )
            self.buttonBottomConstraint.isActive = true
        }
    }
}

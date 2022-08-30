import UIKit
import Combine
import PLAlert

typealias HomeDataSource = UICollectionViewDiffableDataSource<HomeSection, String>
typealias HomeSnapshot = NSDiffableDataSourceSnapshot<HomeSection, String>

final class HomeViewController: UIViewController, AlertPresentable {
    // MARK: - UI Properties
    @IBOutlet weak private var tellMeAJokeButton: UIButton!
    @IBOutlet weak private var streamedImageView: UIImageView!
    @IBOutlet weak private var homeCollectionView: UICollectionView!
    @IBOutlet weak private var confidenceLabel: UILabel!
    @IBOutlet weak private var connectionButton: UIButton!
    @IBOutlet private weak var rangeSlider: RangeSlider!
    @IBOutlet private weak var stopStreamButton: UIButton!
    private let loadingIndicator: ProgressView = {
        let indicator = ProgressView(colors: [.systemPink, .green, .magenta], lineWidth: 6)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    // MARK: - Properties
    var viewModel: HomeViewModelInterface!
    private var datasource: HomeDataSource?
    private var cancellables: Set<AnyCancellable> = .init()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureButton()
        configureBarButtonItem()
        viewModel.viewDidLoad()
        publishUIControlElements()
        registerToBindings()
    }
    private func publishUIControlElements() {
        rangeSlider
            .publisher(for: .valueChanged)
            .compactMap { uiControl in
                uiControl as? RangeSlider
            }
            .sink { [weak self] slider in
                self?.viewModel
                    .inferenceOutputSettingsSubject
                    .send(.init(minimumConfidence: slider.lowerValue, maximumConfidence: slider.upperValue))
            }
            .store(in: &cancellables)
        connectionButton
            .publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.didConnectTapped()
            }
            .store(in: &cancellables)
        stopStreamButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.didStopStreamTapped()
            }
            .store(in: &cancellables)
        tellMeAJokeButton
            .publisher(for: .touchUpInside)
            .throttle(
                for: .seconds(3),
                scheduler: DispatchQueue.main,
                latest: true
            )
            .sink { [weak self] _ in
                self?.viewModel.didTellMeAJokeTapped()
                // test transition without api call
//                self?.navigateToJokeviewController(with: .init(jokeModel: .init(id: 1, joke: "joke"), imageData: (self?.steamedImageView.image?.pngData() ?? Data())))
            }
            .store(in: &cancellables)
    }
    private func registerToBindings() {
        viewModel
            .connectionButtonTextPublisher
            .map { "\($0)" }
            .assign(to: \.titleTextForNormal, on: connectionButton)
            .store(in: &cancellables)
        viewModel
            .connectionStatusPublisher
            .map { $0.color.withAlphaComponent(HomeViewControllerConstants.buttonBackgroundAlphaComponent) }
            .assign(to: \.backgroundColor, on: connectionButton)
            .store(in: &cancellables)
        viewModel
            .connectionStatusPublisher
            .map {
                $0 == .connected ? false : true
            }
            .assign(to: \.isHidden, on: stopStreamButton)
            .store(in: &cancellables)
        // shift into viewModel.. I am a lazy guy
        viewModel
            .inferenceOutputSettingsSubject
            .map {
                "Conf. \(round($0.minimumConfidence * 100) / 100) | \(round($0.maximumConfidence * 100) / 100)"
            }
            .assign(to: \.text, on: confidenceLabel)
            .store(in: &cancellables)
        viewModel
            .snapshotInferenceOutputPublisher
            .sink { [weak self] snapshot in
                self?.datasource?.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        viewModel
            .imageDataSubject
            .sink { [weak self] data in
                self?.streamedImageView.image = UIImage(data: data)
            }
            .store(in: &cancellables)
        viewModel
            .errorMessageToBeShown
            .dropFirst()
            .sink { [weak self] errorMessage in
                self?.tellMeAJokeButton.isEnabled = true
                self?.showAlert(type: PLAlertController.self, title: "Error", message: errorMessage, buttonText: "Cancel")
            }
            .store(in: &cancellables)
        viewModel
            .successMessageToBeShown
            .dropFirst()
            .sink { [weak self] successMessage in
                self?.showAlert(type: PLAlertController.self, title: "Success", message: successMessage, buttonText: "Ok")
            }
            .store(in: &cancellables)
        viewModel
            .jokeToBeShown
            .sink { [weak self] joke in
                self?.tellMeAJokeButton.isEnabled = true
                self?.navigateToJokeviewController(with: joke)
            }
            .store(in: &cancellables)
        viewModel
            .showIndicatorSubject
            .dropFirst()
            .sink { [weak self] state in
                guard let self = self else {
                    return
                }
                // this is a logic isnt it..
                if state {
                    self.setupIndicatorView()
                } else {
                    self.loadingIndicator.isAnimating = false
                }
            }
            .store(in: &cancellables)
    }
    private func configureCollectionView() {
        let cellRegistration = simpleCell()
        datasource = .init(
            collectionView: homeCollectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
                collectionView.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: itemIdentifier
                )
            }
        )
        homeCollectionView.collectionViewLayout = makeCompositionalLayout()
    }
    private func configureButton() {
        tellMeAJokeButton.layer.cornerRadius = HomeViewControllerConstants.tooGeneralConstant
        connectionButton.layer.cornerRadius = HomeViewControllerConstants.tooGeneralConstant
    }
    private func configureBarButtonItem() {
        navigationItem
            .rightBarButtonItem = .init(
                barButtonSystemItem: .edit,
                target: self,
                action: #selector(didTapSettingsButton)
            )
        navigationItem
            .leftBarButtonItem = .init(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(didTapLeftBarButtonItemm)
            )
    }
    private func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        .list(using: .init(appearance: .plain))
    }
    private func simpleCell() -> UICollectionView.CellRegistration<UICollectionViewCell, String> {
        .init { cell, _, itemIdentifier in
            // for know-how..
            var content = UIListContentConfiguration.cell()
            content.text = itemIdentifier
            content.textProperties.colorTransformer = .preferredTint
            content.textProperties.color = .purple
            content.textProperties.adjustsFontForContentSizeCategory = true
            cell.contentConfiguration = content
            var background = UIBackgroundConfiguration.listPlainCell()
            background.backgroundInsets = .init(
                top: .zero,
                leading: HomeViewControllerConstants.insetConstant,
                bottom: HomeViewControllerConstants.insetConstant,
                trailing: HomeViewControllerConstants.insetConstant
            )
            background.cornerRadius = HomeViewControllerConstants.tooGeneralConstant
            background.backgroundColor = .lightGray
            background.visualEffect = UIBlurEffect(style: .light)
            cell.backgroundConfiguration = background
        }
    }
    private func navigateToJokeviewController(with jokeDetailModel: JokeDetailModel) {
        guard let jokeViewController = JokeBuilder.createModule(joke: jokeDetailModel) as? JokeViewController else {
            return
        }
        jokeViewController.setInteractionController()
        navigationController?.delegate = jokeViewController.interactionController
        jokeViewController.interactionController?.fromDelegate = self
        jokeViewController.interactionController?.toDelegate = jokeViewController
        navigationController?.pushViewController(jokeViewController, animated: true)
    }
}
// MARK: - Layout
extension HomeViewController {
    private func setupIndicatorView() {
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingIndicator.widthAnchor.constraint(
                equalToConstant: HomeViewControllerConstants.loadingIndicatorWidthHeight
            ),
            loadingIndicator.heightAnchor.constraint(equalTo: loadingIndicator.widthAnchor)
        ])
        loadingIndicator.isAnimating = true
        loadingIndicator.showDimmingBackground = true
    }
}
// MARK: - Action
extension HomeViewController {
    @objc private func didTapLeftBarButtonItemm(barButton: UIBarButtonItem) {
        guard let controller = CustomPopBuilder.createModule(using: nil) as? CustomPopViewController else {
            return
        }
        controller.modalPresentationStyle = .popover
        controller.preferredContentSize = .init(
            width: UIScreen.main.bounds.width / 1.75,
            height: UIScreen.main.bounds.height / 3.75
        )
        controller.delegate = self
        if let popoverPresentationController = controller.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = [.any]
            popoverPresentationController.barButtonItem = barButton
            popoverPresentationController.delegate = self
            present(controller, animated: true)
        }
    }
    // violation dance
    @objc private func didTapSettingsButton() {
        let settingsViewController = SettingsBuilder.createModule()
        if let settingsViewController = settingsViewController as? SettingsViewController {
            settingsViewController.delegate = self
        }
        let nav = UINavigationController(rootViewController: settingsViewController)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            if #available(iOS 16.0, *) {
                sheet.detents = [
                    .small(),
                    .medium(),
                    .large()
                ]
            } else {
                sheet.detents = [
                    .medium(),
                    .large()
                ]
            }
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = HomeViewControllerConstants.sheetCornerRadius
        }
        present(nav, animated: true)
    }
}
// MARK: - Constants
extension HomeViewController {
    private enum HomeViewControllerConstants {
        static let tooGeneralConstant: CGFloat = 10
        static let buttonBackgroundAlphaComponent: CGFloat = 0.7
        static let insetConstant: CGFloat = 3
        static let loadingIndicatorWidthHeight: CGFloat = 85
        static let sheetCornerRadius: CGFloat = 40
    }
}
// MARK: - SettingsViewController Delegate
extension HomeViewController: SettingsViewControllerDelegate {
    func didCoreModelSelected(_ coreModel: VNCoreMLModelReturnable) {
        viewModel.coreMLModel = coreModel
    }
}
// MARK: - JokeAnimatorDelegate
extension HomeViewController: JokeAnimatorDelegate {
    func animationWillStart() {
        streamedImageView.isHidden = true
        stopStreamButton.isHidden = true
    }
    func animationDidFinish() {
        streamedImageView.isHidden = false
        stopStreamButton.isHidden = false
    }
    func referenceImage(_ animator: JokeAnimator) -> UIImageView {
        streamedImageView
    }
    func referenceFrame(_ animator: JokeAnimator) -> CGRect {
        streamedImageView.frame
    }
}
// MARK: - Delete me Delegate
extension HomeViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}
// MARK: - CustomPopViewControllerDelegate
extension HomeViewController: CustomPopViewControllerDelegate {
    func didUserSavedText(_ text: String) {
        viewModel.didWebSocketUrlStringRequested(text)
    }
}

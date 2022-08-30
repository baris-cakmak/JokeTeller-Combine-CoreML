import UIKit
import Combine

typealias SettingsDataSource = UICollectionViewDiffableDataSource<SettingsSection, String>
typealias SettingsSnapshot = NSDiffableDataSourceSnapshot<SettingsSection, String>

protocol SettingsViewControllerDelegate: AnyObject {
    func didCoreModelSelected(_ coreModel: VNCoreMLModelReturnable)
}

final class SettingsViewController: UIViewController {
    // MARK: - UI Properties
    private lazy var settingsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeSettingsCompositionalLayout())
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    // MARK: - Properties
    private var dataSource: SettingsDataSource?
    private var cancellables: Set<AnyCancellable> = .init()
    var viewModel: SettingsViewModelInterface?
    // MARK: - Delegate
    weak var delegate: SettingsViewControllerDelegate?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        view.addSubview(settingsCollectionView)
        layoutCollectionView()
        registerToBindings()
    }
}
// MARK: - Constant
extension SettingsViewController {
    private enum SettingsViewControllerConstants {
        static let cornerRadius: CGFloat = 10
    }
}
// MARK: - Layout
extension SettingsViewController {
    private func layoutCollectionView() {
        NSLayoutConstraint.activate([
            settingsCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            settingsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            settingsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            settingsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
// MARK: - Helper
extension SettingsViewController {
    private func sideBarRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, String> {
        .init { cell, _, itemIdentifier in
            var content = UIListContentConfiguration.cell()
            content.text = itemIdentifier
            content.textProperties.color = .label
            cell.contentConfiguration = content
            var background = UIBackgroundConfiguration.listSidebarCell()
            background.cornerRadius = SettingsViewControllerConstants.cornerRadius
            cell.backgroundConfiguration = background
        }
    }
    private func configureCollectionView() {
        let cellRegistration = sideBarRegistration()
        dataSource = .init(
            collectionView: settingsCollectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
    private func makeSettingsCompositionalLayout() -> UICollectionViewCompositionalLayout {
        .list(using: .init(appearance: .sidebar))
    }
    private func registerToBindings() {
        viewModel?
            .snapshotSubject
            .sink { [weak self] snapshot in
                self?.dataSource?.apply(snapshot)
            }
            .store(in: &cancellables)
        viewModel?
            .coreMLModelSubject
            .sink { [weak self] model in
                self?.delegate?.didCoreModelSelected(model)
            }
            .store(in: &cancellables)
    }
}
// MARK: - UICollectionView Delegate
extension SettingsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.saveCoreMLModel(at: indexPath)
    }
}

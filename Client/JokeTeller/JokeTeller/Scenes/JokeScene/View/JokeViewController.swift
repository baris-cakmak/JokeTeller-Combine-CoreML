import UIKit
import Combine

final class JokeViewController: UIViewController, JokeTransitionable {
    // MARK: - Properties
    var interactionController: JokeAnimatorController?
    var viewModel: JokeViewModelInterface!
    private var cancellables: Set<AnyCancellable> = .init()
    // MARK: - UI Properties
    @IBOutlet private weak var jokeTextView: UITextView!
    @IBOutlet private weak var capturedImageView: UIImageView!
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerToBindings()
        viewModel.viewDidLoad()
        // test
        addTapDismissGestureRecognizer()
    }
}
// MARK: - Helper
extension JokeViewController {
    private func addTapDismissGestureRecognizer() {
        let tapGesture: UITapGestureRecognizer = .init(target: self, action: #selector(handleTapGesture))
        view.addGestureRecognizer(tapGesture)
    }
    private func registerToBindings() {
        // do some weird stuff
        viewModel
            .jokeTextSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                self?.jokeTextView.text = text
            }
            .store(in: &cancellables)
        viewModel
            .imageDataSubject
            .sink { [weak self] data in
                self?.capturedImageView.image = .init(data: data)
            }
            .store(in: &cancellables)
    }
}
// MARK: - JokeAnimatorDelegate
extension JokeViewController: JokeAnimatorDelegate {
    func animationWillStart() {
        capturedImageView.isHidden = true
    }
    func animationDidFinish() {
        capturedImageView.isHidden = false
    }
    func referenceImage(_ animator: JokeAnimator) -> UIImageView {
        capturedImageView
    }
    func referenceFrame(_ animator: JokeAnimator) -> CGRect {
        view.setNeedsLayout()
        view.layoutIfNeeded()
        return capturedImageView.frame
    }
}
// MARK: - Actions
extension JokeViewController {
    @objc private func handleTapGesture(gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

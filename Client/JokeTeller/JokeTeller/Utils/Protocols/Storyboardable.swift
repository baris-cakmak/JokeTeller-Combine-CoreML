import UIKit

enum StoryboardName: String {
    case main
    case jokeStoryboard
    var identifier: String {
        rawValue.prefix(1).capitalized + rawValue.dropFirst()
    }
}
protocol Storyboardable {
    static var storyboardBundle: Bundle { get }
    static var storyboardIdentifier: String { get }
    static func instantiate(with storybardName: StoryboardName) -> Self
}
// MARK: - Extension
extension Storyboardable where Self: UIViewController {
    static var storyboardBundle: Bundle {
        .main
    }
    static var storyboardIdentifier: String {
        String(describing: self)
    }
    static func instantiate(with storybardName: StoryboardName) -> Self {
        guard let viewController = UIStoryboard(
            name: storybardName.identifier,
            bundle: storyboardBundle
        ).instantiateViewController(withIdentifier: storyboardIdentifier) as? Self else {
            fatalError("Storyboard Instantiations")
        }
        return viewController
    }
}

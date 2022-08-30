import UIKit
// swiftlint:disable all
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        let nav = UINavigationController()
        let homeViewController = HomeBuilder.createModule(coreMLModel: nil)
        nav.pushViewController(homeViewController, animated: false)
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
    }
}


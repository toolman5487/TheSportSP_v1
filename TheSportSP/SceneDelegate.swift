//
//  SceneDelegate.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2025/1/14.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        APINetworkConfig.baseURL = "https://www.thesportsdb.com/api/v1/json"
        configureNavigationBarAppearance()

        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .dark
        window.tintColor = ColorConfig.themeColor

        let rootViewController = IndexController()
        window.rootViewController = rootViewController
        self.window = window
        window.makeKeyAndVisible()
    }

    private func configureNavigationBarAppearance() {
        let navBar = UINavigationBar.appearance()
        navBar.prefersLargeTitles = true
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

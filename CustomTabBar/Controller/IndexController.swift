//
//  IndexController.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/1/24.
//

import UIKit
import SnapKit

@MainActor
final class IndexController: UIViewController {
    
    private var currentChildViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        showMainApplication()
    }
    
    func showMainApplication() {
        let tabBarController = TabBarConfiguration.makeTabBarController()
        transitionToViewController(tabBarController)
    }
    
    private func transitionToViewController(_ viewController: UIViewController) {
        if let currentVC = currentChildViewController {
            currentVC.willMove(toParent: nil)
            currentVC.view.removeFromSuperview()
            currentVC.removeFromParent()
        }
        
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        viewController.didMove(toParent: self)
        
        currentChildViewController = viewController
    }
}

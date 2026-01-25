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
        transitionToViewController(tabBarController, animated: false)
    }
    
    private func transitionToViewController(_ viewController: UIViewController, animated: Bool = true) {
        guard viewController !== currentChildViewController else { return }
        
        let previousVC = currentChildViewController
        
        if let previousVC = previousVC {
            previousVC.willMove(toParent: nil)
            
            if animated {
                UIView.transition(
                    with: view,
                    duration: 0.3,
                    options: [.transitionCrossDissolve, .allowUserInteraction],
                    animations: {
                        previousVC.view.alpha = 0
                    },
                    completion: { _ in
                        previousVC.view.removeFromSuperview()
                        previousVC.removeFromParent()
                    }
                )
            } else {
                previousVC.view.removeFromSuperview()
                previousVC.removeFromParent()
            }
        }
        
        addChild(viewController)
        view.addSubview(viewController.view)
        
        viewController.view.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if animated && previousVC != nil {
            viewController.view.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction]) {
                viewController.view.alpha = 1
            }
        }
        
        viewController.didMove(toParent: self)
        currentChildViewController = viewController
    }
}

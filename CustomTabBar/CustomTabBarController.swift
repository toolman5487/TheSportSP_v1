//
//  CustomTabBarController.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/1/18.
//

import UIKit
import SnapKit

@MainActor
final class CustomTabBarController: UIViewController {
    
    // MARK: - Properties
    
    private var viewControllers: [UIViewController] = []
    private var currentViewController: UIViewController?
    
    // MARK: - UI Components
    
    let customTabBar: CustomTabBar = {
        let tabBar = CustomTabBar()
        return tabBar
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if customTabBar.superview != nil && view.subviews.last !== customTabBar {
            view.bringSubviewToFront(customTabBar)
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(containerView)
        view.addSubview(customTabBar)
        
        customTabBar.delegate = self
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        customTabBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Public Methods
    
    func setViewControllers(_ viewControllers: [UIViewController], tabBarItems: [TabBarItem]) {
        self.viewControllers = viewControllers
        customTabBar.configure(with: tabBarItems)
        
        if let firstVC = viewControllers.first {
            showViewController(firstVC)
        }
    }
    
    // MARK: - Private Methods
    
    private func showViewController(_ viewController: UIViewController) {
        guard viewController !== currentViewController else { return }
        
        if let currentVC = currentViewController {
            currentVC.willMove(toParent: nil)
            currentVC.view.removeFromSuperview()
            currentVC.removeFromParent()
        }
        
        addChild(viewController)
        containerView.addSubview(viewController.view)
        viewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        viewController.didMove(toParent: self)
        currentViewController = viewController
    }
}

// MARK: - CustomTabBarDelegate

extension CustomTabBarController: CustomTabBarDelegate {
    func didSelectTab(at index: Int) {
        guard index >= 0 && index < viewControllers.count else { return }
        
        let viewController = viewControllers[index]
        
        if viewController === currentViewController {
            if let refreshable = viewController as? TabBarRefreshable {
                refreshable.refreshContent()
            }
            return
        }
        
        showViewController(viewController)
        customTabBar.selectTab(at: index)
    }
}

// MARK: - TabBarRefreshable Protocol

protocol TabBarRefreshable {
    func refreshContent()
}

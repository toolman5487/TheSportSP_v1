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
    
    private let viewModel = TabBarViewModel()
    
    private var viewControllerFactories: [() -> UIViewController] = []
    
    private var cachedViewControllers: [Int: UIViewController] = [:]
    
    private var currentViewController: UIViewController?
    
    // MARK: - UI Components
    
    private(set) var customTabBar: CustomTabBar = {
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
        view.bringSubviewToFront(customTabBar)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(containerView)
        view.addSubview(customTabBar)
        
        customTabBar.delegate = self
        customTabBar.viewModel = viewModel
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        customTabBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Public Methods
    
    func setViewControllers(factories: [() -> UIViewController], tabBarItems: [TabBarItem], tabTypes: [TabType]) {
        self.viewControllerFactories = factories
        viewModel.configure(with: tabTypes)
        customTabBar.configure(with: tabBarItems)
        
        if let firstTab = tabTypes.first {
            viewModel.selectedTab = firstTab
            
            if let firstVC = getOrCreateViewController(at: 0) {
                showViewController(firstVC)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func getOrCreateViewController(at index: Int) -> UIViewController? {
        if let cachedVC = cachedViewControllers[index] {
            return cachedVC
        }
        
        guard index >= 0 && index < viewControllerFactories.count else { return nil }
        let factory = viewControllerFactories[index]
        let newVC = factory()
        cachedViewControllers[index] = newVC
        
        addChild(newVC)
        containerView.addSubview(newVC.view)
        newVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        newVC.didMove(toParent: self)
        
        newVC.view.isHidden = true
        
        return newVC
    }
    
    private func showViewController(_ viewController: UIViewController) {
        guard viewController !== currentViewController else { return }
        
        currentViewController?.view.isHidden = true
        
        viewController.view.isHidden = false
        containerView.bringSubviewToFront(viewController.view)
        
        currentViewController = viewController
    }
}

// MARK: - CustomTabBarDelegate

extension CustomTabBarController: CustomTabBarDelegate {
    func didSelectTab(at index: Int) {
        guard let viewController = getOrCreateViewController(at: index) else { return }
        
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

@MainActor
protocol TabBarRefreshable {
    func refreshContent()
}

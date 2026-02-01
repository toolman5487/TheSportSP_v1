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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        showMainApplication()
    }
    
    private func showMainApplication() {
        let tabBarController = TabBarConfiguration.makeTabBarController()
        
        addChild(tabBarController)
        view.addSubview(tabBarController.view)
        
        tabBarController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tabBarController.didMove(toParent: self)
    }
}

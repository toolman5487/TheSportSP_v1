//
//  TabBarConfiguration.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/1/18.
//

import UIKit

enum TabType {
    case home
    case search
    case profile
    
    var item: TabBarItem {
        switch self {
        case .home:
            return TabBarItem(
                title: "Home",
                iconName: "house",
                selectedIconName: "house.fill",
                displayMode: .iconOnly
            )
        case .search:
            return TabBarItem(
                title: "Search",
                iconName: "magnifyingglass",
                displayMode: .iconOnly,
                animationStyle: .animated(.colorChange)
            )
        case .profile:
            return TabBarItem(
                title: "Profile",
                iconName: "person",
                selectedIconName: "person.fill",
                displayMode: .iconOnly,
                animationStyle: .animated(.pulse)
            )
        }
    }
    
    func makeViewController() -> UIViewController {
        return UINavigationController(rootViewController: ViewController())
    }
}

struct TabBarConfiguration {
    static let tabs: [TabType] = [.home, .search, .profile]
    
    static func makeTabBarController() -> CustomTabBarController {
        let tabBarController = CustomTabBarController()
        let viewControllers = tabs.map { $0.makeViewController() }
        let tabBarItems = tabs.map { $0.item }
        
        tabBarController.setViewControllers(viewControllers, tabBarItems: tabBarItems, tabTypes: tabs)
        return tabBarController
    }
}

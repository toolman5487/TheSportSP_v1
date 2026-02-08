//
//  TabBarConfiguration.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/1/18.
//

import UIKit

enum TabType: Sendable {
    case home
    case events
    case athlete
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
        case .events:
            return TabBarItem(
                title: "Events",
                iconName: "flag.2.crossed",
                selectedIconName: "flag.2.crossed.fill",
                displayMode: .iconOnly
            )
        case .athlete:
            return TabBarItem(
                title: "athlete",
                iconName: "trophy",
                selectedIconName: "trophy.fill",
                displayMode: .iconOnly
            )
        case .profile:
            return TabBarItem(
                title: "Profile",
                iconName: "person",
                selectedIconName: "person.fill",
                displayMode: .iconOnly
            )
        }
    }
    
    func makeViewController() -> UIViewController {
        switch self {
        case .home:
            let homeVC = MainHomeViewController()
            return UINavigationController(rootViewController: homeVC)
        case .events, .athlete, .profile:
            let vc = ViewController()
            vc.title = "Placeholder"
            return UINavigationController(rootViewController: vc)
        }
    }
}

struct TabBarConfiguration {
    static let tabs: [TabType] = [.home, .events, .athlete, .profile]
    
    static func makeTabBarController() -> CustomTabBarController {
        let tabBarController = CustomTabBarController()
        
        let factories: [() -> UIViewController] = tabs.map { tab in
            return { tab.makeViewController() }
        }
        
        let tabBarItems = tabs.map { $0.item }
        
        tabBarController.setViewControllers(factories: factories, tabBarItems: tabBarItems, tabTypes: tabs)
        return tabBarController
    }
}

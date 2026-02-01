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
    case leagues
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
                iconName: "calendar",
                selectedIconName: "calendar.fill",
                displayMode: .iconOnly
            )
        case .leagues:
            return TabBarItem(
                title: "Leagues",
                iconName: "person.3",
                selectedIconName: "person.3.fill",
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
        return UINavigationController(rootViewController: ViewController())
    }
}

struct TabBarConfiguration {
    static let tabs: [TabType] = [.home, .events, .leagues, .profile]
    
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

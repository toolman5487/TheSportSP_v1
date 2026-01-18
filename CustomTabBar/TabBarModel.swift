//
//  TabBarModel.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/1/18.
//

import UIKit

enum TabBarDisplayMode {
    case iconOnly
    case iconWithText
}

struct TabBarItem {
    let title: String
    let icon: UIImage?
    let selectedIcon: UIImage?
    let displayMode: TabBarDisplayMode
    
    init(
        title: String,
        iconName: String,
        selectedIconName: String? = nil,
        displayMode: TabBarDisplayMode = .iconWithText
    ) {
        self.title = title
        self.icon = UIImage(systemName: iconName)
        self.selectedIcon = selectedIconName != nil 
            ? UIImage(systemName: selectedIconName!) 
            : self.icon
        self.displayMode = displayMode
    }
}

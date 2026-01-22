//
//  TabBarModel.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/1/18.
//

import UIKit

enum TabBarDisplayMode: Equatable {
    case iconOnly
    case iconWithText
}

struct TabBarItem: Equatable {
    let title: String
    let icon: UIImage?
    let selectedIcon: UIImage?
    let displayMode: TabBarDisplayMode
    
    static func == (lhs: TabBarItem, rhs: TabBarItem) -> Bool {
        return lhs.title == rhs.title &&
               lhs.displayMode == rhs.displayMode &&
               lhs.icon?.pngData() == rhs.icon?.pngData() &&
               lhs.selectedIcon?.pngData() == rhs.selectedIcon?.pngData()
    }
    
    init(
        title: String,
        iconName: String,
        selectedIconName: String? = nil,
        displayMode: TabBarDisplayMode = .iconWithText
    ) {
        self.title = title
        self.icon = UIImage(systemName: iconName)
        self.selectedIcon = selectedIconName.flatMap { UIImage(systemName: $0) } ?? self.icon
        self.displayMode = displayMode
    }
}

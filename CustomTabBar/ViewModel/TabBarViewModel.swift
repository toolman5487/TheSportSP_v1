//
//  TabBarViewModel.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/1/24.
//

import Foundation
import Combine

@MainActor
final class TabBarViewModel: ObservableObject {
    
    @Published private(set) var visitedTabs: Set<TabType> = []
    @Published private(set) var tabTypes: [TabType] = []
    @Published private(set) var notifications: Set<TabType> = []
    @Published var selectedTab: TabType? {
        didSet {
            guard let selectedTab = selectedTab, selectedTab != oldValue else { return }
            markAsVisited(selectedTab)
            clearNotification(for: selectedTab)
        }
    }
    
    private var tabTypeToIndex: [TabType: Int] = [:]
    
    func configure(with tabTypes: [TabType]) {
        self.tabTypes = tabTypes
        tabTypeToIndex = Dictionary(uniqueKeysWithValues: tabTypes.enumerated().map { ($0.element, $0.offset) })
        visitedTabs.removeAll()
    }
    
    func markAsVisited(_ tab: TabType) {
        visitedTabs.insert(tab)
    }
    
    func shouldPulse(at index: Int) -> Bool {
        guard index >= 0 && index < tabTypes.count else { return false }
        let tab = tabTypes[index]
        return shouldPulse(for: tab)
    }
    
    func shouldPulse(for tab: TabType) -> Bool {
        let item = tab.item
        let hasNotification = notifications.contains(tab)
        let shouldPulseForUnvisited = item.animationStyle == .pulse && !visitedTabs.contains(tab)
        return hasNotification || shouldPulseForUnvisited
    }
    
    func setNotification(for tab: TabType, hasNotification: Bool) {
        if hasNotification {
            notifications.insert(tab)
        } else {
            notifications.remove(tab)
        }
    }
    
    func clearNotification(for tab: TabType) {
        notifications.remove(tab)
    }
    
    func clearAllNotifications() {
        notifications.removeAll()
    }
    
    func resetVisitedState() {
        visitedTabs.removeAll()
    }
    
    func index(for tab: TabType) -> Int? {
        return tabTypeToIndex[tab]
    }
    
    func tab(at index: Int) -> TabType? {
        guard index >= 0 && index < tabTypes.count else { return nil }
        return tabTypes[index]
    }
}

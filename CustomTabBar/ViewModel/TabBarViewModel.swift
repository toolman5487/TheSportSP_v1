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
    
    // MARK: - Published Properties
    
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
    
    // MARK: - Private Properties
    
    private var tabTypeToIndex: [TabType: Int] = [:]
    
    // MARK: - Configuration
    
    func configure(with tabTypes: [TabType]) {
        self.tabTypes = tabTypes
        tabTypeToIndex = Dictionary(uniqueKeysWithValues: tabTypes.enumerated().map { ($0.element, $0.offset) })
        visitedTabs.removeAll()
    }
    
    // MARK: - Animation State
    
    private(set) var colorAnimatingTabs: Set<TabType> = []
    
    func startColorAnimation(for tab: TabType) {
        colorAnimatingTabs.insert(tab)
    }
    
    func stopColorAnimation(for tab: TabType) {
        colorAnimatingTabs.remove(tab)
    }
    
    func isColorAnimating(_ tab: TabType) -> Bool {
        colorAnimatingTabs.contains(tab)
    }
    
    func markAsVisited(_ tab: TabType) {
        visitedTabs.insert(tab)
    }
    
    func needsAnimation(at index: Int) -> Bool {
        guard let tab = tab(at: index) else { return false }
        return needsAnimation(for: tab)
    }
    
    func needsAnimation(for tab: TabType) -> Bool {
        let item = tab.item
        guard case .animated = item.animationStyle else { return notifications.contains(tab) }
        let isUnvisited = !visitedTabs.contains(tab)
        return isUnvisited || notifications.contains(tab)
    }
    
    func animationKind(for tab: TabType) -> TabBarAnimationKind? {
        guard case .animated(let kind) = tab.item.animationStyle else { return nil }
        return kind
    }
    
    // MARK: - Notifications
    
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
    
    // MARK: - Index Mapping
    
    func index(for tab: TabType) -> Int? {
        return tabTypeToIndex[tab]
    }
    
    func tab(at index: Int) -> TabType? {
        guard index >= 0 && index < tabTypes.count else { return nil }
        return tabTypes[index]
    }
}

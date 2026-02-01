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
    
    /// 正在執行變色動畫的 tab（由 View 在開始/停止時更新，completion 依此判斷是否繼續）
    private(set) var runningColorChangeAnimationTabs: Set<TabType> = []
    
    func markColorChangeAnimationStarted(for tab: TabType) {
        runningColorChangeAnimationTabs.insert(tab)
    }
    
    func markColorChangeAnimationStopped(for tab: TabType) {
        runningColorChangeAnimationTabs.remove(tab)
    }
    
    func isColorChangeAnimationRunning(for tab: TabType) -> Bool {
        runningColorChangeAnimationTabs.contains(tab)
    }
    
    func markAsVisited(_ tab: TabType) {
        visitedTabs.insert(tab)
    }
    
    func shouldAnimateTab(at index: Int) -> Bool {
        guard index >= 0 && index < tabTypes.count else { return false }
        let tab = tabTypes[index]
        return shouldAnimateTab(for: tab)
    }
    
    func shouldAnimateTab(for tab: TabType) -> Bool {
        let item = tab.item
        let hasNotification = notifications.contains(tab)
        let shouldAnimateForUnvisited: Bool
        if case .animated = item.animationStyle {
            shouldAnimateForUnvisited = !visitedTabs.contains(tab)
        } else {
            shouldAnimateForUnvisited = false
        }
        return hasNotification || shouldAnimateForUnvisited
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

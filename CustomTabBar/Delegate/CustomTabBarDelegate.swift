//
//  CustomTabBarDelegate.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/1/18.
//

import Foundation

@MainActor
protocol CustomTabBarDelegate: AnyObject {
    func didSelectTab(at index: Int)
}

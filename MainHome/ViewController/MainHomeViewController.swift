//
//  MainHomeViewController.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/2/6.
//

import UIKit
import SnapKit

final class MainHomeViewController: MainHomeBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
    }
    
    // MARK: - Navigation
    
    private func setUpNavigationBar() {
        title = "Home"
     
    }
}

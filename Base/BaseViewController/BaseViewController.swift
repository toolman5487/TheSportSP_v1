//
//  BaseViewController.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/2/7.
//

import UIKit

@MainActor
class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func setup() {
        view.backgroundColor = .systemBackground
        configureNavigationBar()
        configureDismissKeyboard()
    }

    func configureNavigationBar() {
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    func configureDismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

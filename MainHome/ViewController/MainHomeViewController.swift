//
//  MainHomeViewController.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/2/6.
//

import UIKit
import SnapKit

@MainActor
final class MainHomeViewController: MainHomeBaseViewController {

    private enum Section: Int, CaseIterable {
        case carousel
    }

    private static let carouselHeight: CGFloat = 180

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setupCollectionView()
    }

    // MARK: - Navigation

    private func setUpNavigationBar() {
        title = "Home"
    }

    // MARK: - Setup

    private func setupCollectionView() {
        collectionView.register(MainHomeCarouselCell.self, forCellWithReuseIdentifier: MainHomeCarouselCell.reuseId)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    private var carouselImageNames: [String] {
        [
            "sportscourt.fill",
            "figure.run",
            "trophy.fill",
            "medal.fill",
        ]
    }
}

// MARK: - UICollectionViewDataSource

extension MainHomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard Section(rawValue: section) == .carousel else { return 0 }
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainHomeCarouselCell.reuseId, for: indexPath) as? MainHomeCarouselCell ?? MainHomeCarouselCell()
        cell.configure(imageNames: carouselImageNames)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MainHomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right)
        guard Section(rawValue: indexPath.section) == .carousel else { return .zero }
        return CGSize(width: width, height: Self.carouselHeight)
    }
}

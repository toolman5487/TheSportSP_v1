//
//  MainHomeViewController.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/2/6.
//

import UIKit
import SnapKit
import Combine

@MainActor
final class MainHomeViewController: MainHomeBaseViewController {

    private enum Section: Int, CaseIterable {
        case carousel
    }

    private static let carouselHeight: CGFloat = 180

    private let viewModel = MainHomeViewModel()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setupCollectionView()
        bindViewModel()
        viewModel.loadCarousel()
    }

    // MARK: - Navigation

    private func setUpNavigationBar() {
        title = nil
        navigationItem.largeTitleDisplayMode = .never
    }

    // MARK: - Setup

    private func setupCollectionView() {
        collectionView.register(MainHomeCarouselCell.self, forCellWithReuseIdentifier: MainHomeCarouselCell.reuseId)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    private func bindViewModel() {
        viewModel.$carouselItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
                self?.endRefreshing()
            }
            .store(in: &cancellables)
    }

    override func handleRefresh() {
        viewModel.loadCarousel()
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
        let items = viewModel.carouselItems
        if items.isEmpty {
            cell.configure(imageNames: [])
        } else {
            cell.configure(items: items)
        }
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

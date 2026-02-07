//
//  MainHomeBaseViewController.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/2/4.
//

import UIKit
import SnapKit

@MainActor
class MainHomeBaseViewController: BaseViewController {
    
    // MARK: - Properties
    
    private let layout: UICollectionViewLayout
    private(set) lazy var refreshControl = UIRefreshControl()
    
    // MARK: - UI Components
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = true
        return collectionView
    }()
    
    // MARK: - Initialization
    
    init(layout: UICollectionViewLayout = UICollectionViewFlowLayout()) {
        if let flowLayout = layout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = 8
            flowLayout.minimumInteritemSpacing = 0
        }
        self.layout = layout
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControl()
    }
    
    // MARK: - Setup
    
    override func setup() {
        super.setup()
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupRefreshControl() {
        collectionView.refreshControl = refreshControl
        refreshControl.addAction(
            UIAction { [weak self] _ in
                self?.handleRefresh()
            },
            for: .valueChanged
        )
    }
    
    // MARK: - Refresh

    func handleRefresh() {
    }
    
    func endRefreshing() {
        guard refreshControl.isRefreshing else { return }
        refreshControl.endRefreshing()
    }
}

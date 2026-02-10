//
//  MainHomeOptionsContainerCell.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/2/10.
//

import UIKit
import SnapKit

@MainActor
final class MainHomeOptionsContainerCell: UICollectionViewCell {

    static let reuseId = "MainHomeOptionsContainerCell"

    private var sports: [SportsDBSport] = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        view.dataSource = self
        view.delegate = self
        view.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.register(MainHomeOptionCell.self, forCellWithReuseIdentifier: MainHomeOptionCell.reuseId)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func configure(with sports: [SportsDBSport]) {
        self.sports = sports
        collectionView.reloadData()
    }
}

extension MainHomeOptionsContainerCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sports.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MainHomeOptionCell.reuseId,
            for: indexPath
        ) as? MainHomeOptionCell else {
            return UICollectionViewCell()
        }
        let sport = sports[indexPath.item]
        cell.configure(with: sport.strSport ?? "")
        return cell
    }
}


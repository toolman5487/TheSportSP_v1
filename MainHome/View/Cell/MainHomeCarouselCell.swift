//
//  MainHomeCarouselCell.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/2/7.
//

import UIKit
import SnapKit

// MARK: - MainHomeCarouselCell

@MainActor
final class MainHomeCarouselCell: UICollectionViewCell {

    static let reuseId = "MainHomeCarouselCell"

    private let carouselView: CarouselView = CarouselView()

    private var carouselItems: [MainCarouselModel] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentView.addSubview(carouselView)
        carouselView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func configure(imageNames: [String]) {
        carouselItems = []
        carouselView.configure(imageNames: imageNames)
    }

    func configure(imageURLs: [String]) {
        carouselItems = imageURLs.map { MainCarouselModel(imageURL: $0) }
        carouselView.configure(imageURLs: imageURLs)
    }

    func configure(items: [MainCarouselModel]) {
        carouselItems = items
        let urls = items.map { $0.imageURL ?? "" }
        let titles = items.map { $0.title }
        carouselView.configure(imageURLs: urls, titles: titles)
    }
}

//
//  MainHomeCarouselCell.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/2/7.
//

import UIKit
import SnapKit

@MainActor
final class MainHomeCarouselCell: UICollectionViewCell {

    static let reuseId = "MainHomeCarouselCell"

    private let itemWidthRatio: CGFloat = 0.82
    private let itemSpacing: CGFloat = 16

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = itemSpacing
        layout.minimumInteritemSpacing = 0
        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        v.isPagingEnabled = false
        v.showsHorizontalScrollIndicator = false
        v.decelerationRate = .fast
        v.backgroundColor = .clear
        v.delegate = self
        v.dataSource = self
        v.register(CarouselImageCell.self, forCellWithReuseIdentifier: CarouselImageCell.reuseId)
        return v
    }()

    private let pageControl: UIPageControl = {
        let v = UIPageControl()
        v.currentPageIndicatorTintColor = .label
        v.pageIndicatorTintColor = .tertiaryLabel
        v.hidesForSinglePage = true
        return v
    }()

    private var imageNames: [String] = []
    private var timerHandlerId: UUID?
    private let autoScrollInterval: TimeInterval = 3
    private var lastAutoScrollTime: Date = .distantPast
    private var currentIndex: Int = 0
    private var count: Int { imageNames.count }
    /// 佈局為 [最後一張, 第0張, 第1張, ..., 倒數第二張, 第一張]，讓首尾兩側都能露出相鄰卡，像圓環
    private var totalCount: Int { count > 1 ? count + 2 : count }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        if let id = timerHandlerId {
            GlobalTimer.shared.removeHandler(id)
            timerHandlerId = nil
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil, let id = timerHandlerId {
            GlobalTimer.shared.removeHandler(id)
            timerHandlerId = nil
        }
    }

    private func setup() {
        contentView.addSubview(collectionView)
        contentView.addSubview(pageControl)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
        }
    }

    func configure(imageNames: [String]) {
        self.imageNames = imageNames.isEmpty ? [""] : imageNames
        pageControl.numberOfPages = count
        pageControl.currentPage = 0
        currentIndex = count > 1 ? 1 : 0
        collectionView.reloadData()
        if count > 1, window != nil {
            startAutoScroll()
        }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if self.count > 1 {
                self.collectionView.setContentOffset(CGPoint(x: self.contentOffsetX(forIndex: 1), y: 0), animated: false)
            }
            self.updateDepthForVisibleCells()
        }
    }

    private func startAutoScroll() {
        guard timerHandlerId == nil else { return }
        lastAutoScrollTime = Date()
        timerHandlerId = GlobalTimer.shared.addHandler { [weak self] in
            guard let self else { return }
            let now = Date()
            guard now.timeIntervalSince(self.lastAutoScrollTime) >= self.autoScrollInterval else { return }
            self.lastAutoScrollTime = now
            self.advanceToNextPage()
        }
    }

    private func itemWidth() -> CGFloat {
        collectionView.bounds.width * itemWidthRatio
    }

    private func sideInset() -> CGFloat {
        (collectionView.bounds.width - itemWidth()) / 2
    }

    private func contentOffsetX(forIndex index: Int) -> CGFloat {
        let w = collectionView.bounds.width
        let iw = itemWidth()
        let inset = sideInset()
        return inset + CGFloat(index) * (iw + itemSpacing) + iw / 2 - w / 2
    }

    private func nearestIndex(forContentOffsetX offsetX: CGFloat) -> Int {
        let iw = itemWidth()
        let inset = sideInset()
        let raw = (offsetX + collectionView.bounds.width / 2 - inset - iw / 2) / (iw + itemSpacing)
        return max(0, min(totalCount - 1, Int(round(raw))))
    }

    private func logicalPage(forItemIndex itemIndex: Int) -> Int {
        guard count > 1 else { return 0 }
        return (itemIndex + count - 1) % count
    }

    private func advanceToNextPage() {
        guard count > 1 else { return }
        var nextIndex = currentIndex + 1
        if nextIndex >= totalCount {
            nextIndex = 1
            collectionView.setContentOffset(CGPoint(x: contentOffsetX(forIndex: 1), y: 0), animated: false)
        } else {
            collectionView.setContentOffset(CGPoint(x: contentOffsetX(forIndex: nextIndex), y: 0), animated: true)
        }
        currentIndex = nextIndex
        pageControl.currentPage = logicalPage(forItemIndex: currentIndex)
    }

    private func normalizeOffsetIfNeeded() {
        guard count > 1, collectionView.bounds.width > 0 else { return }
        let index = nearestIndex(forContentOffsetX: collectionView.contentOffset.x)
        if index == 0 {
            collectionView.setContentOffset(CGPoint(x: contentOffsetX(forIndex: totalCount - 2), y: 0), animated: false)
            currentIndex = totalCount - 2
        } else if index == totalCount - 1 {
            collectionView.setContentOffset(CGPoint(x: contentOffsetX(forIndex: 1), y: 0), animated: false)
            currentIndex = 1
        } else {
            currentIndex = index
        }
        pageControl.currentPage = logicalPage(forItemIndex: currentIndex)
    }

    private func snapToNearestIndex() {
        let index = nearestIndex(forContentOffsetX: collectionView.contentOffset.x)
        let targetX = contentOffsetX(forIndex: index)
        collectionView.setContentOffset(CGPoint(x: targetX, y: 0), animated: true)
        currentIndex = index
        pageControl.currentPage = logicalPage(forItemIndex: currentIndex)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension MainHomeCarouselCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselImageCell.reuseId, for: indexPath) as? CarouselImageCell ?? CarouselImageCell()
        let imageIndex = (indexPath.item + count - 1) % count
        let name = imageNames[safe: imageIndex] ?? ""
        cell.configure(systemName: name)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: itemWidth(), height: collectionView.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = sideInset()
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        var index = nearestIndex(forContentOffsetX: targetContentOffset.pointee.x)
        if index == 0 { index = totalCount - 2 }
        else if index == totalCount - 1 { index = 1 }
        targetContentOffset.pointee.x = contentOffsetX(forIndex: index)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateDepthForVisibleCells()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        normalizeOffsetIfNeeded()
        updateDepthForVisibleCells()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        normalizeOffsetIfNeeded()
        updateDepthForVisibleCells()
    }

    private func updateDepthForVisibleCells() {
        let width = collectionView.bounds.width
        guard width > 0 else { return }
        let centerX = collectionView.bounds.midX
        collectionView.visibleCells.forEach { cell in
            guard let carouselCell = cell as? CarouselImageCell else { return }
            let offset = (cell.frame.midX - centerX) / width
            let absNormalized = min(1, abs(offset))
            let scale = 1 - 0.12 * absNormalized
            let alpha = 1 - 0.3 * absNormalized
            carouselCell.applyDepth(scale: scale, alpha: alpha)
        }
    }
}

// MARK: - CarouselImageCell

private final class CarouselImageCell: UICollectionViewCell {
    static let reuseId = "CarouselImageCell"
    private let imageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.clipsToBounds = true
        v.tintColor = .label
        v.backgroundColor = .tertiarySystemFill
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }


    func configure(systemName: String) {
        if !systemName.isEmpty {
            imageView.image = UIImage(systemName: systemName)
        } else {
            imageView.image = nil
        }
        imageView.backgroundColor = .tertiarySystemFill
    }

    func applyDepth(scale: CGFloat, alpha: CGFloat) {
        contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
        contentView.alpha = alpha
    }
}

// MARK: - Safe subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

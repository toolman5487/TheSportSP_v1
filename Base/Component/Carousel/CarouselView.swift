//
//  CarouselView.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/2/7.
//

import UIKit
import SnapKit
import SDWebImage

// MARK: - CarouselView

@MainActor
final class CarouselView: UIView {

    // MARK: - Configuration

    private let itemWidthRatio: CGFloat = 0.82
    private let itemSpacing: CGFloat = 16
    private let autoScrollInterval: TimeInterval = 3

    // MARK: - Subviews

    private let depthEffect = CarouselDepthEffect()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = itemSpacing
        layout.minimumInteritemSpacing = 0
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.isPagingEnabled = false
        view.showsHorizontalScrollIndicator = false
        view.decelerationRate = .fast
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        view.register(CarouselViewImageCell.self, forCellWithReuseIdentifier: CarouselViewImageCell.reuseId)
        return view
    }()

    private let pageControl: UIPageControl = {
        let view = UIPageControl()
        view.currentPageIndicatorTintColor = .label
        view.pageIndicatorTintColor = .tertiaryLabel
        view.hidesForSinglePage = true
        return view
    }()

    // MARK: - State

    private var imageNames: [String] = []
    private var imageURLs: [String] = []
    private var titles: [String?] = []
    private var useURLs: Bool = false
    private var timerHandlerId: UUID?
    private var lastAutoScrollTime: Date = .distantPast
    private var isUserInteracting: Bool = false
    private var currentIndex: Int = 0
    private var count: Int { useURLs ? imageURLs.count : imageNames.count }
    private var totalCount: Int { count > 1 ? count + 2 : count }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Lifecycle

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            if let id = timerHandlerId {
                GlobalTimer.shared.removeHandler(id)
                timerHandlerId = nil
            }
        } else if count > 1 {
            startAutoScroll()
        }
    }

    // MARK: - Setup

    private func setup() {
        addSubview(collectionView)
        addSubview(pageControl)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        depthEffect.configurePerspective(on: collectionView.layer)
    }

    // MARK: - Public

    func configure(imageNames: [String]) {
        useURLs = false
        imageURLs = []
        self.imageNames = imageNames.isEmpty ? [""] : imageNames
        applyConfigure()
    }

    func configure(imageURLs: [String], titles: [String?]? = nil) {
        useURLs = true
        imageNames = []
        self.imageURLs = imageURLs.isEmpty ? [""] : imageURLs
        self.titles = titles ?? []
        applyConfigure()
    }

    private func applyConfigure() {
        if let id = timerHandlerId {
            GlobalTimer.shared.removeHandler(id)
            timerHandlerId = nil
        }
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

    // MARK: - Private Helpers

    private func startAutoScroll() {
        guard timerHandlerId == nil else { return }
        lastAutoScrollTime = Date()
        timerHandlerId = GlobalTimer.shared.addHandler { [weak self] in
            guard let self else { return }
            guard !self.isUserInteracting else { return }
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
            collectionView.layoutIfNeeded()
        } else {
            collectionView.setContentOffset(CGPoint(x: contentOffsetX(forIndex: nextIndex), y: 0), animated: true)
        }
        currentIndex = nextIndex
        pageControl.currentPage = logicalPage(forItemIndex: currentIndex)
    }

    private func normalizeOffsetIfNeeded() {
        guard count > 1, collectionView.bounds.width > 0 else { return }
        let index = nearestIndex(forContentOffsetX: collectionView.contentOffset.x)
        let didJump: Bool
        if index == 0 {
            collectionView.setContentOffset(CGPoint(x: contentOffsetX(forIndex: totalCount - 2), y: 0), animated: false)
            currentIndex = totalCount - 2
            didJump = true
        } else if index == totalCount - 1 {
            collectionView.setContentOffset(CGPoint(x: contentOffsetX(forIndex: 1), y: 0), animated: false)
            currentIndex = 1
            didJump = true
        } else {
            currentIndex = index
            didJump = false
        }
        pageControl.currentPage = logicalPage(forItemIndex: currentIndex)
        if didJump {
            collectionView.layoutIfNeeded()
            DispatchQueue.main.async { [weak self] in
                self?.updateDepthForVisibleCells()
            }
        }
    }

    private func updateDepthForVisibleCells() {
        depthEffect.updateDepth(collectionView: collectionView, transformProvider: Self.castToDepthApplicable)
    }

    private static func castToDepthApplicable(_ cell: UICollectionViewCell) -> CarouselDepthApplicable? {
        cell as? CarouselDepthApplicable
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension CarouselView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselViewImageCell.reuseId, for: indexPath) as? CarouselViewImageCell ?? CarouselViewImageCell()
        let imageIndex = (indexPath.item + count - 1) % count
        if useURLs {
            let urlString = imageURLs[safe: imageIndex] ?? ""
            let title = titles[safe: imageIndex] ?? nil
            cell.configure(imageURLString: urlString, title: title)
        } else {
            let name = imageNames[safe: imageIndex] ?? ""
            cell.configure(systemName: name)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: itemWidth(), height: collectionView.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = sideInset()
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isUserInteracting = true
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
        isUserInteracting = false
        lastAutoScrollTime = Date()
        normalizeOffsetIfNeeded()
        updateDepthForVisibleCells()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isUserInteracting = false
        lastAutoScrollTime = Date()
        normalizeOffsetIfNeeded()
        updateDepthForVisibleCells()
    }
}

// MARK: - CarouselViewImageCell

private final class CarouselViewImageCell: UICollectionViewCell, CarouselDepthApplicable {
    static let reuseId = "CarouselViewImageCell"

    private static let placeholderImage: UIImage? = {
        let config = UIImage.SymbolConfiguration(pointSize: 48, weight: .light)
        return UIImage(systemName: "photo", withConfiguration: config)?
            .withTintColor(.tertiaryLabel, renderingMode: .alwaysTemplate)
    }()

    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.tintColor = .label
        return view
    }()

    private let gradientOverlayLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.5).cgColor,
        ]
        layer.locations = [0.3, 1.0]
        return layer
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.layer.addSublayer(gradientOverlayLayer)
        contentView.addSubview(titleLabel)
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.clipsToBounds = true
        layer.cornerRadius = 12
        layer.masksToBounds = true
        backgroundColor = .tertiarySystemBackground
        contentView.backgroundColor = .clear

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(4)
            make.bottom.equalToSuperview().inset(12)
            make.height.greaterThanOrEqualTo(44)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientOverlayLayer.frame = contentView.bounds
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.sd_cancelCurrentImageLoad()
        imageView.image = nil
        imageView.backgroundColor = .tertiarySystemFill
        titleLabel.text = nil
        titleLabel.attributedText = nil
        titleLabel.isHidden = true
        contentView.layer.transform = CATransform3DIdentity
        contentView.transform = .identity
        contentView.alpha = 1
    }

    func configure(systemName: String) {
        imageView.sd_cancelCurrentImageLoad()
        if !systemName.isEmpty {
            imageView.image = UIImage(systemName: systemName)
        } else {
            imageView.image = nil
        }
        imageView.backgroundColor = .tertiarySystemFill
        titleLabel.text = nil
        titleLabel.isHidden = true
        accessibilityLabel = String(localized: "Carousel item")
        accessibilityTraits = [.button]
    }

    func configure(imageURLString: String, title: String? = nil) {
        imageView.sd_cancelCurrentImageLoad()
        if let url = URL(string: imageURLString), !imageURLString.isEmpty {
            let scale = UIScreen.main.scale
            let thumbnailPixelSize = CGSize(width: 800 * scale, height: 600 * scale)
            let context: [SDWebImageContextOption: Any] = [
                SDWebImageContextOption.imageThumbnailPixelSize: NSValue(cgSize: thumbnailPixelSize),
            ]
            imageView.sd_setImage(
                with: url,
                placeholderImage: Self.placeholderImage,
                context: context
            )
        } else {
            imageView.image = nil
        }
        imageView.backgroundColor = .clear
        if let title, !title.isEmpty {
            titleLabel.attributedText = title.attributedWithShadow(font: .boldSystemFont(ofSize: 20))
            titleLabel.isHidden = false
            accessibilityLabel = title
        } else {
            titleLabel.text = nil
            titleLabel.isHidden = true
            accessibilityLabel = String(localized: "Carousel image")
        }
        accessibilityTraits = [.button]
        accessibilityHint = String(localized: "Double tap to view")
    }

    func applyDepth2D(scaleX: CGFloat, scaleY: CGFloat, alpha: CGFloat) {
        contentView.layer.transform = CATransform3DIdentity
        contentView.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        contentView.alpha = alpha
    }

    func applyDepth3D(rotationY: CGFloat, scale: CGFloat, alpha: CGFloat) {
        contentView.transform = .identity
        var transform = CATransform3DIdentity
        transform = CATransform3DRotate(transform, rotationY, 0, 1, 0)
        transform = CATransform3DScale(transform, scale, scale, 1)
        contentView.layer.transform = transform
        contentView.alpha = alpha
    }
}

// MARK: - Safe subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

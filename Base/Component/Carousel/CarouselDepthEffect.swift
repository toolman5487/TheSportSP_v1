//
//  CarouselDepthEffect.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/2/7.
//

import UIKit

// MARK: - CarouselDepthApplicable

protocol CarouselDepthApplicable: AnyObject {
    func applyDepth2D(scaleX: CGFloat, scaleY: CGFloat, alpha: CGFloat)
    func applyDepth3D(rotationY: CGFloat, scale: CGFloat, alpha: CGFloat)
}

// MARK: - CarouselDepthEffect

@MainActor
final class CarouselDepthEffect {

    var perspectiveStrength: CGFloat = -1 / 800
    var scaleXFactor: CGFloat = 0.38
    var scaleYFactor: CGFloat = 0.52
    var rotationYFactor: CGFloat = 0.45
    var scale3DFactor: CGFloat = 0.35
    var alphaFactor: CGFloat = 0.55

    init() {}

    func configurePerspective(on layer: CALayer) {
        var perspective = CATransform3DIdentity
        perspective.m34 = perspectiveStrength
        layer.sublayerTransform = perspective
    }

    func updateDepth(
        collectionView: UICollectionView,
        transformProvider: @MainActor (UICollectionViewCell) -> CarouselDepthApplicable?
    ) {
        let width = collectionView.bounds.width
        guard width > 0 else { return }
        let centerXInContent = collectionView.contentOffset.x + width / 2
        let use3D = !UIAccessibility.isReduceMotionEnabled
        collectionView.visibleCells.forEach { cell in
            guard let target = transformProvider(cell) else { return }
            let offset = (cell.frame.midX - centerXInContent) / width
            let absNormalized = min(1, abs(offset))
            let alpha = 1 - alphaFactor * absNormalized
            if use3D {
                let rotationY = -offset * rotationYFactor
                let scale = 1 - scale3DFactor * absNormalized
                target.applyDepth3D(rotationY: rotationY, scale: scale, alpha: alpha)
            } else {
                let scaleX = 1 - scaleXFactor * absNormalized
                let scaleY = 1 - scaleYFactor * absNormalized
                target.applyDepth2D(scaleX: scaleX, scaleY: scaleY, alpha: alpha)
            }
        }
    }
}

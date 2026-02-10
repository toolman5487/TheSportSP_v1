//
//  MainHomeOptionCell.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/2/10.
//

import UIKit
import SnapKit

@MainActor
final class MainHomeOptionCell: UICollectionViewCell {

    static let reuseId = "MainHomeOptionCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
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
        contentView.addSubview(titleLabel)

        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.masksToBounds = true

        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12))
        }

        updateAppearance()
        isAccessibilityElement = true
        accessibilityTraits.insert(.button)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = contentView.bounds.height / 2
    }

    override var isSelected: Bool {
        didSet { updateAppearance() }
    }

    private func updateAppearance() {
        if isSelected {
            contentView.backgroundColor = .label
            titleLabel.textColor = .systemBackground
        } else {
            contentView.backgroundColor = .secondarySystemBackground
            titleLabel.textColor = .label
        }
    }

    func configure(with sportName: String) {
        titleLabel.text = sportName
        accessibilityLabel = sportName
    }
}


//
//  String+TextShadow.swift
//  TheSportSP
//

import UIKit

extension String {
    func attributedWithShadow(
        font: UIFont,
        color: UIColor = .label,
        shadowColor: UIColor = UIColor.black.withAlphaComponent(0.6),
        shadowBlurRadius: CGFloat = 3
    ) -> NSAttributedString {
        let shadow = NSShadow()
        shadow.shadowColor = shadowColor
        shadow.shadowOffset = .zero
        shadow.shadowBlurRadius = shadowBlurRadius
        return NSAttributedString(
            string: self,
            attributes: [
                .font: font,
                .foregroundColor: color,
                .shadow: shadow,
            ]
        )
    }
}

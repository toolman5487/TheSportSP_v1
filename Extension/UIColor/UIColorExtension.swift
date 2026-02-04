//
//  UIColorExtension.swift
//  TheSportSP
//
//  Created by Willy Hsu on 2026/2/3.
//

import UIKit

extension UIColor {

    static func hex(_ hex: String) -> UIColor? {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }
        guard !hexSanitized.isEmpty,
              let value = UInt64(hexSanitized, radix: 16) else { return nil }
        let count = hexSanitized.count
        guard count == 6 || count == 8 else { return nil }
        if count == 6 {
            let r = CGFloat((value >> 16) & 0xFF) / 255
            let g = CGFloat((value >> 8) & 0xFF) / 255
            let b = CGFloat(value & 0xFF) / 255
            return UIColor(red: r, green: g, blue: b, alpha: 1)
        } else {
            let r = CGFloat((value >> 24) & 0xFF) / 255
            let g = CGFloat((value >> 16) & 0xFF) / 255
            let b = CGFloat((value >> 8) & 0xFF) / 255
            let a = CGFloat(value & 0xFF) / 255
            return UIColor(red: r, green: g, blue: b, alpha: a)
        }
    }

    var hexString: String? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }
        let r = Int(round(red * 255))
        let g = Int(round(green * 255))
        let b = Int(round(blue * 255))
        return String(format: "%02x%02x%02x", r, g, b)
    }
}

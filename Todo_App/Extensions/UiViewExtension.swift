//
//  UiViewExtension.swift
//  Todo_App
//
//  Created by admin on 30/10/25.
//

import UIKit

extension UIView {

    // MARK: - Corner Radius
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            if newValue > 0 {
                layer.masksToBounds = true
            }
        }
    }

    // MARK: - Border Width
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    // MARK: - Border Color
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let cgColor = layer.borderColor else { return nil }
            return UIColor(cgColor: cgColor)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

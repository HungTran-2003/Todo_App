//
//  UiNavigationBar.swift
//  Todo_App
//
//  Created by admin on 17/10/25.
//

import UIKit

extension UINavigationBar {
    func applyAppearance(backgroundColor: UIColor) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor
        appearance.shadowColor = .clear
    }
        
}

//
//  Application.swift
//  Todo_App
//
//  Created by admin on 27/10/25.
//

import UIKit

final class Application: NSObject {
    static let shared = Application()

    var window: UIWindow?

    var supabase: SupabaseManager
    
    private override init() {
        supabase = SupabaseManager.shared
        super.init()
    }

    func presentInitialScreen(in window: UIWindow?) {
        
    }
}

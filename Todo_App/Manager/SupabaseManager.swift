//
//  SupabaseManager.swift
//  Todo_App
//
//  Created by admin on 17/10/25.
//

import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    private final let supabaseKey = Bundle.main.object(forInfoDictionaryKey: "SupaBase_KEY") as? String ?? ""
    private final let supabaseURL = Bundle.main.object(forInfoDictionaryKey: "SupaBase_URL") as? String ?? ""

    let client: SupabaseClient

    private init() {
        print(supabaseURL)
        
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://\(supabaseURL)")!,
            supabaseKey: supabaseKey
        )
    }
}

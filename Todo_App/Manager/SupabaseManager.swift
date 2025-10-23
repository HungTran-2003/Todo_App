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

    let client: SupabaseClient

    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://imejzeuyhsoqpibieyjh.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImltZWp6ZXV5aHNvcXBpYmlleWpoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA1NzMyMjEsImV4cCI6MjA3NjE0OTIyMX0.PEyDllRl2SzyGqIWXrczmwgainWQuakdZYJCa_OUrB4"
        )
    }
}

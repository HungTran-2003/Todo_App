//
//  AuthService.swift
//  Todo_App
//
//  Created by admin on 20/10/25.
//

import Supabase
class AuthService {
    
    static let share = AuthService()
    
    private let keyChain = KeychainManager.share
    
    init() {}
    
    
    
    func loginAnonymously() async throws -> Bool{
        if let refréhToken = keyChain.readFromKeyChain(key: keyChain.key_refreshToken) {
            
            let session = try await SupabaseManager.shared.client.auth.refreshSession(refreshToken: refréhToken)
            
            keyChain.saveToKeychain(session.accessToken, keyChain.key_accessToken)
            keyChain.saveToKeychain(session.refreshToken, keyChain.key_refreshToken)
            
            return true
        } else {
            let session = try await SupabaseManager.shared.client.auth.signInAnonymously()
            
            keyChain.saveToKeychain(session.accessToken, keyChain.key_accessToken)
            keyChain.saveToKeychain(session.refreshToken, keyChain.key_refreshToken)
            return true
        }
    }
    
    
}

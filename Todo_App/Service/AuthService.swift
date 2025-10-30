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
    
    func signInAnonymously() async throws -> Bool {
        let session = try await SupabaseManager.shared.client.auth.signInAnonymously()

        keyChain.saveToKeychain(session.accessToken, keyChain.key_accessToken)
        keyChain.saveToKeychain(session.refreshToken, keyChain.key_refreshToken)
        return true
    }

    func refreshSession() async throws -> Bool {
        guard let refreshToken = keyChain.readFromKeyChain(key: keyChain.key_refreshToken) else {
            return false
        }

        let session = try await SupabaseManager.shared.client.auth.refreshSession(refreshToken: refreshToken)

        keyChain.saveToKeychain(session.accessToken, keyChain.key_accessToken)
        keyChain.saveToKeychain(session.refreshToken, keyChain.key_refreshToken)

        return true
    }

    func loginAnonymously() async throws -> Bool {
        if let _ = keyChain.readFromKeyChain(key: keyChain.key_refreshToken) {
            do {
                return try await refreshSession()
            } catch {
                return try await signInAnonymously()
            }
        } else {
            return try await signInAnonymously()
        }
    }

    
}

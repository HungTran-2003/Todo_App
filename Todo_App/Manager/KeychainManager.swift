//
//  KeychainManager.swift
//  Todo_App
//
//  Created by admin on 20/10/25.
//

import Foundation

class KeychainManager {
    
    static let share = KeychainManager()
    
    let key_refreshToken = Bundle.main.object(forInfoDictionaryKey: "key_refreshToken") as? String ?? ""
    let key_accessToken = Bundle.main.object(forInfoDictionaryKey: "key_accessToken") as? String ?? ""
    
    private init() {}
    
    func readFromKeyChain(key: String) -> String?{
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
                let data = item as? Data,
                let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        return value
    }
    
    func saveToKeychain(_ value: String,_ key: String) {
        let data = value.data(using: .utf8)!

            // Xóa trước nếu đã tồn tại (tránh trùng)
        SecItemDelete([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ] as CFDictionary)

            // Thêm mới
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
                // Lưu an toàn, truy cập được sau khi unlock lần đầu
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemAdd(query as CFDictionary, nil)
    }
}

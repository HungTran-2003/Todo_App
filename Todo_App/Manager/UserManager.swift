//
//  UserManager.swift
//  Todo_App
//
//  Created by admin on 17/10/25.
//
import Foundation
import Security

class UserManager {
    
    static let share = UserManager()
    
    private init() {}
    
    private let key = "com.newwaresll.uniqueUserID"
    
    func getUserId() -> String{
        if let userId = readFromKeyChain(){
            return userId
        } else {
            let newId = UUID().uuidString
            saveToKeychain(newId)
            return newId
        }
    }
    
    func readFromKeyChain() -> String?{
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
    
    private func saveToKeychain(_ value: String) {
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

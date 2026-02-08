//
//  KeychainHelper.swift
//  Phantom
//
//  Created on 2/7/2026.
//

import Foundation
import Security

enum KeychainHelper {
    
    enum Key: String {
        case accessToken = "phantom.accessToken"
        case idToken = "phantom.idToken"
        case refreshToken = "phantom.refreshToken"
    }
    
    static func save(_ value: String, for key: Key) {
        guard let data = value.data(using: .utf8) else { return }
        
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecAttrService as String: "com.phantom.auth",
        ]
        SecItemDelete(deleteQuery as CFDictionary)
        
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecAttrService as String: "com.phantom.auth",
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]
        SecItemAdd(addQuery as CFDictionary, nil)
    }
    
    static func read(_ key: Key) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecAttrService as String: "com.phantom.auth",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    static func delete(_ key: Key) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecAttrService as String: "com.phantom.auth",
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    static func deleteAll() {
        delete(.accessToken)
        delete(.idToken)
        delete(.refreshToken)
    }
}

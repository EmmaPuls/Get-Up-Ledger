import Foundation
import Security

/// Stores the Up Bank API token in the Keychain rather than UserDefaults.
///
/// UserDefaults is plain-text on disk and, once the app is sandboxed, lives in
/// the per-app container — so a token saved by a non-sandboxed build is invisible
/// to the sandboxed one. The Keychain avoids both problems: it is encrypted and
/// survives the sandbox transition.
enum KeychainStore {
    /// Matches the app's bundle identifier so the item is namespaced to this app.
    private static let service = "com.epuls.Get-Up-App"
    /// The single account/key under which the API token is stored.
    static let apiKeyAccount = "upBankAPIKey"

    /// The legacy UserDefaults key the token used to be stored under.
    private static let legacyUserDefaultsKey = "upBankAPIKey"

    /// Reads the stored token, or `nil` if none is set.
    static func get(_ account: String = apiKeyAccount) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
              let data = item as? Data,
              let value = String(data: data, encoding: .utf8)
        else {
            return nil
        }
        return value
    }

    /// Stores `value` for `account`. An empty string deletes the item.
    static func set(_ value: String, account: String = apiKeyAccount) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            delete(account)
            return
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        let attributes: [String: Any] = [
            kSecValueData as String: Data(trimmed.utf8),
            // Token isn't needed before first unlock and shouldn't sync to iCloud.
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            SecItemAdd(query.merging(attributes) { $1 } as CFDictionary, nil)
        }
    }

    /// Removes the stored token for `account`.
    static func delete(_ account: String = apiKeyAccount) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        SecItemDelete(query as CFDictionary)
    }

    /// One-time migration: if a token exists in legacy UserDefaults but not yet in
    /// the Keychain, copy it over and clear the UserDefaults copy. Safe to call on
    /// every launch — it no-ops once the Keychain holds the token.
    static func migrateFromUserDefaultsIfNeeded() {
        guard get() == nil,
              let legacy = UserDefaults.standard.string(forKey: legacyUserDefaultsKey),
              !legacy.isEmpty
        else {
            return
        }
        set(legacy)
        UserDefaults.standard.removeObject(forKey: legacyUserDefaultsKey)
    }
}

//
//  KeychainStore.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 21.08.20.
//

import Foundation

// Following the tutorial https://www.raywenderlich.com/9240-keychain-services-api-tutorial-for-passwords-in-swift to implement keychain access to this app
// Keychain access is needed in this application to store the password on the device which is used for authenticating when connecting to the server. This prevents the user from having to enter the password each time the application is started. Just once on the first setup.
// Apples Keychain API implemention is quite poor. It's helpful to create a own wrapper.

struct KeychainStore {
    let keychainStoreQueryable: KeychainStoreQueryable
    
    func setValue(_ value: String, for userAccountName: String) throws {
        guard let encodedPassword = value.data(using: .utf8) else {
            throw KeychainStoreErrors.string2DataConversionError
        }
        
        var query = keychainStoreQueryable.query
        query[String(kSecAttrAccount)] = userAccountName
           
        let searchStatus = SecItemCopyMatching(query as CFDictionary, nil) // Will scan the current keychain scope for existing entrys with the username in the query
        
        
        switch searchStatus {
            case errSecSuccess:
                return
            case errSecItemNotFound:
                query[String(kSecValueData)] = encodedPassword
                
                let addStatus = SecItemAdd(query as CFDictionary, nil)
                
                if addStatus != errSecSuccess {
                    throw KeychainStoreErrors.addToStoreError(returnSingal: String(addStatus))
                }
            default:
                throw KeychainStoreErrors.unhandledError(message: "Error occurred when searching for elements in keychain with exit code: \(searchStatus)")
        }
        
    }
//
//    func checkExistsValue(for userAccountName: String) throws -> Bool {
//        var query = keychainStoreQueryable.query
//        query[String(kSecAttrAccount)] = userAccountName
//
//        let searchStatus = SecItemCopyMatching(query as CFDictionary, nil)
//
//        switch searchStatus {
//            case errSecSuccess:
//                return true
//            case errSecItemNotFound:
//                return false
//            default:
//                fatalError("Error checking if a password for the username is stored.")
//        }
//    }
    
    func getValue(for userAccountName: String) throws -> String? {
        var query = keychainStoreQueryable.query
        query[String(kSecMatchLimit)] = kSecMatchLimitOne
        query[String(kSecReturnAttributes)] = kCFBooleanTrue
        query[String(kSecReturnData)] = kCFBooleanTrue
        query[String(kSecAttrAccount)] = userAccountName
        
        var queryResult: AnyObject?
        let findStatus = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, $0)
        }
        
        switch findStatus {
            case errSecSuccess:
                guard let queriedItem = queryResult as? [String: Any],
                      let passwordData = queriedItem[String(kSecValueData)] as? Data,
                      let password = String(data: passwordData, encoding: .utf8)
                else {
                    throw KeychainStoreErrors.data2StringConversionError
                }
                
                return password
            case errSecItemNotFound:
                print("There is no user with the account name \(userAccountName)")
                return nil
            default:
                throw KeychainStoreErrors.unhandledError(message: "Error when retriving a stored item from the keychain scope. Non-expected return code \(findStatus)")
        }
    }
    
    func removeValue(for userAccount: String) throws -> Bool {
        var query = keychainStoreQueryable.query
        query[String(kSecAttrAccount)] = userAccount
        
        let deleteStatus = SecItemDelete(query as CFDictionary)
        
        switch deleteStatus {
            case errSecSuccess:
                return true
            case errSecItemNotFound:
                return false
        default:
            throw KeychainStoreErrors.unhandledError(message: "Error when deleting a user account. Non-expected return code \(deleteStatus)")
        }
    }
    
    func removeAllValues() throws -> Bool {
        let query = keychainStoreQueryable.query
        
        let allDeleteStatus = SecItemDelete(query as CFDictionary)
        
        switch allDeleteStatus {
            case errSecSuccess:
                return true
            case errSecItemNotFound:
                return false
        default:
            throw KeychainStoreErrors.unhandledError(message: "Error when deleting a user account. Non-expected return code \(allDeleteStatus)")
        }
    }
}

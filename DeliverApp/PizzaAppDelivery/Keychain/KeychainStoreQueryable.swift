//
//  KeychainStoreQueryable.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 21.08.20.
//

import Foundation

protocol KeychainStoreQueryable {
    var query: [String: Any] {get}
}

struct PasswordQueryable {
    let service: String
}

extension PasswordQueryable: KeychainStoreQueryable {
    var query: [String: Any] {
        var insideQuery = [String: Any]()
        insideQuery[String(kSecClass)] = kSecClassGenericPassword
        insideQuery[String(kSecAttrService)] = self.service
        
        return insideQuery
    }
}

//
//  CheckAccountStored.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 21.08.20.
//

import CoreData
import Foundation
import SwiftUI

func checkGetUsernameStored(usernames: [UserData]) -> String? {
    // Checks if there is any stored usernames in the apps CoreData storage. If it finds one it returns the username otherwise returns nil
    
    print("Checked if a username is stored.")
    print(usernames)
//    if usernames.count == 0 {
//        return nil
//    } else if usernames.count == 1 {
//        return usernames[0].username
//    } else if usernames.count > 1 {
//        print("!! Warning: There are multiple entrys of the UserData CoreData entity. Only max one entry should exist of the UserData entity. Will use the first UserData entry found.")
//        return usernames[0].username
//    }
//
    return nil
}

func checkGetPasswordStored(username: String, keychainStore: KeychainStore) -> String? {
    var passwordStored: String?
    
    do {
        passwordStored = try keychainStore.getValue(for: username)
    } catch {
        fatalError("Could not read password from keychain.")
    }
    
    if passwordStored != nil {
        return passwordStored
    } else {
        return nil
    }
}

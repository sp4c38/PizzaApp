//
//  VerifyAccountStored.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 21.08.20.
//

import CoreData
import Foundation
import SwiftUI

func verifyAccountStored(usernames: FetchedResults<UserData>, keychainStore: KeychainStore) -> String? {
    let usernameStored = checkGetUsernameStored(usernames: usernames)
    let passwordStored: Bool
    
    if usernameStored != nil {
        // Account is stored
        // don't need to login
        
        do {
            passwordStored = try keychainStore.checkExistsValue(for: usernameStored!)
        } catch {
            fatalError("Could not read password from keychain.")
        }
        
        if passwordStored{
            return usernameStored
        } else {
            // This should normally not be run because it would mean that a username is stored but no password for the username is stored
            fatalError("A username is stored but has no stored password")
            //return nil
        }
    } else {
        // No account is yet logged-in
        // need to log in an account
        
        return nil
    }
}

func saveAccount(username: String, password: String, managedObjectContext: NSManagedObjectContext, keychainStore: KeychainStore) -> Bool {
    if checkCorrectLogin(username: username, password: password) {
        let loggedinAccount = UserData(context: managedObjectContext) // Register an entry for only the username as an UserData CoreData entry
        loggedinAccount.username = username
        
        do {
            try keychainStore.setValue(password, for: username)
        } catch {
           fatalError("Couldn't create a keychain entry. \(error)")
        }
        
        do {
            try managedObjectContext.save() // Save the CoreData entry
        } catch {
            fatalError("Couldn't save a new user account in CoreData. \(error)")
        }
        
        return true
    } else {
        return false
    }
}

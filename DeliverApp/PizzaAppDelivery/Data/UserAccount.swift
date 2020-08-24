//
//  VerifyAccountStored.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 21.08.20.
//

import CoreData
import Foundation
import SwiftUI

func verifyAccountStored(usernameStored: String, keychainStore: KeychainStore) -> Bool {
    print("Checked if username and password are valid.")
    
    let passwordStored: String?
    
    passwordStored = checkGetPasswordStored(username: usernameStored, keychainStore: keychainStore)
        
    if passwordStored != nil {
        if checkCorrectLogin(username: usernameStored, password: passwordStored!) {
            return true
        } else {
            // Login details aren't valid anymore
            return false
        }
    } else {
        // This should normally not occur because it would mean that a username is stored but no password for the username is stored
        fatalError("A username is stored but has no stored password")
        //return nil
    }
}

func checkAndSaveAccount(username: String, password: String, managedObjectContext: NSManagedObjectContext, keychainStore: KeychainStore) -> Bool {
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

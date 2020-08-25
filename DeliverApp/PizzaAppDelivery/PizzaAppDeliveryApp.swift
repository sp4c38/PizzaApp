//
//  PizzaAppDeliveryApp.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 21.08.20.
//

import CoreData
import SwiftUI

class PersistenceManager {
    var persistentContainer: NSPersistentContainer {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error {
                fatalError("Unresolved error occurred. \(error)")
            }
        })
        return container
    }
}

struct KeychainStoreKey: EnvironmentKey {
    static let defaultValue: KeychainStore = KeychainStore(keychainStoreQueryable: PasswordQueryable(service: "UserAccountService"))
}

extension EnvironmentValues {
    var keychainStore: KeychainStore {
        get { self[KeychainStoreKey.self] }
        set { self[KeychainStoreKey.self] = newValue }
    }
}

@main
struct PizzaAppDeliveryApp: App {
    var body: some Scene {
        let persistence = PersistenceManager()
        let context = persistence.persistentContainer.viewContext
        
        let queryType = PasswordQueryable(service: "UserAccountService")
        let keychainStore = KeychainStore(keychainStoreQueryable: queryType)
        
        return WindowGroup {
            ContentView()
                .environment(\.keychainStore, keychainStore)
                .environment(\.managedObjectContext, context)
        }
    }
}

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

@main
struct PizzaAppDeliveryApp: App {
    var body: some Scene {
        let persistence = PersistenceManager()
        let context = persistence.persistentContainer.viewContext
        
        return WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, context)
        }
    }
}

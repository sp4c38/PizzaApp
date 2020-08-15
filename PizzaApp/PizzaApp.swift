//
//  PizzaApp.swift
//  PizzaApp
//
//  Created by Léon Becker on 13.08.20.
//

import SwiftUI
import CoreData

class PersistenceManager {
    var persistentContainer: NSPersistentContainer {
        let container = NSPersistentContainer(name: "PizzaApp")
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error {
                fatalError("Unresolved error occurred. \(error)")
            }
        })
        return container
    }
}

@main
struct PizzaApp_App: App {
    var persistence = PersistenceManager() // Since there is not AppDelegate and SceneDelegate in modern SwiftUI Applications a own PersistenceManager needs to be created
    
    var body: some Scene {
        WindowGroup {
            HomeView().environment(\.managedObjectContext, persistence.persistentContainer.viewContext)
        }
    }
}

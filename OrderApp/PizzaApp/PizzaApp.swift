//
//  PizzaApp.swift
//  PizzaApp
//
//  Created by Léon Becker on 13.08.20.
//

import CoreData
import SwiftUI

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

class OrderProperty: ObservableObject {
    @Published var showOrderSuccessful: Bool = false
}

@main
struct PizzaApp_App: App {
    var persistence = PersistenceManager()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistence.persistentContainer.viewContext)
                .environmentObject(OrderProperty())
        }
    }
}

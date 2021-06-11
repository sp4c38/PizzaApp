//
//  PizzaTechApp.swift
//  PizzaTech
//
//  Created by Léon Becker on 05.03.21.
//

import CoreData
import SwiftUI
import OSLog

struct PizzaTechServices: ViewModifier {
    static var catalogService = CatalogService()

    func body(content: Content) -> some View {
        content
            .environmentObject(Self.catalogService)
    }
}

class PersistenceManager {
    var persistentContainer: NSPersistentContainer {
        let container = NSPersistentContainer(name: "PizzaTech")
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error {
                fatalError("Unresolved error occurred. \(error)")
            }
        })
        return container
    }
}


let logger = Logger(.default)

@main
struct PizzaTechApp: App {
    var catalogService = CatalogService()
    var persistenceManager = PersistenceManager()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(catalogService)
                .environment(\.managedObjectContext, persistenceManager.persistentContainer.viewContext)
        }
    }
}

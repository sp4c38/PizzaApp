//
//  PizzaTechApp.swift
//  PizzaTech
//
//  Created by Léon Becker on 05.03.21.
//

import SwiftUI
import OSLog

struct PizzaTechServices: ViewModifier {
    static var catalogService = CatalogService()
    
    func body(content: Content) -> some View {
        content
            .environmentObject(Self.catalogService)
    }
}

let logger = Logger(.default)

@main
struct PizzaTechApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .modifier(PizzaTechServices())
        }
    }
}

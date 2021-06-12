//
//  PizzaTechDeliverAppApp.swift
//  PizzaTechDeliverApp
//
//  Created by Léon Becker on 12.06.21.
//

import SwiftUI

struct PizzaTechServices: ViewModifier {
    static var catalogService = CatalogService()

    func body(content: Content) -> some View {
        content
            .environmentObject(Self.catalogService)
    }
}



class OrdersService: ObservableObject {
    @Published var orders: Orders? = nil
}

@main
struct PizzaTechDeliverAppApp: App {
    var catalogService = CatalogService()
    var ordersService = OrdersService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(catalogService)
                .environmentObject(ordersService)
        }
    }
}

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
    static var previewCatalogService: CatalogService = {
        let catalogService = CatalogService()
        catalogService.fetchCatalog()
        return catalogService
    }()
    
    private func servicesForPreview(_ content: Content) -> some View {
        content
            .environmentObject(Self.previewCatalogService)
    }
    
    private func services(_ content: Content) -> some View {
        content
            .environmentObject(Self.catalogService)
    }
    
    func body(content: Content) -> some View {
        #if PREVIEW
            return servicesForPreview(content)
        #else
           return services(content)
        #endif
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

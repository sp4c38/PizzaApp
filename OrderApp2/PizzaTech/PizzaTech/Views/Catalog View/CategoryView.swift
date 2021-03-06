//
//  CategoryView.swift
//  PizzaTech
//
//  Created by Léon Becker on 05.03.21.
//

import SwiftUI

struct CategorySelection: View {
    @EnvironmentObject var catalogService: CatalogService
    var categories: [String] {
        catalogService.catalog!.categories
    }
    
    var body: some View {
        HStack {
            ForEach(0..<categories.count) { categoryID in
                Button(action: {
                    catalogService.setCategorySelection(to: categoryID)
                }) {
                    Text(categories[categoryID])
                }
            }
            Text(catalogService.catalog!.iceDessert.items[0].name.description)
        }
    }
}

struct CategoryView: View {
    var body: some View {
        VStack {
            CategorySelection()
            CurrentCategory()
        }
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView()
            .environmentObject(previewCatalogService)
            
    }
}

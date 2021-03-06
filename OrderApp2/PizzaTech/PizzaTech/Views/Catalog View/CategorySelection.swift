//
//  CategorySelection.swift
//  PizzaTech
//
//  Created by Léon Becker on 06.03.21.
//

import SwiftUI

struct CategorySelectionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.white)
            .padding([.top, .bottom], 4)
            .padding([.leading, .trailing], 8)
            
            .background(Color.blue)
            .cornerRadius(6)
            
            .shadow(radius: 3)
    }
}

struct CategorySelectionButton: View {
    @EnvironmentObject var catalogService: CatalogService
    
    let categoryID: CategoryID
    let categoryName: String
    
    init(identifier: CategoryID, name: String) {
        self.categoryID = identifier
        self.categoryName = name
    }
    
    var body: some View {
        Button(action: {
            onCategorySelection()
        }) {
            Text(categoryName)
        }
        .buttonStyle(CategorySelectionButtonStyle())
    }
    
    func onCategorySelection() {
        catalogService.setCategorySelection(to: categoryID)
    }
}

struct CategorySelection: View {
    @EnvironmentObject var catalogService: CatalogService
    var categories: Categories {
        catalogService.catalog!.categories
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 15) {
//                ForEach(categories.categoryIDs) { categoryID in
//                    CategorySelectionButton(
//                        identifier: categoryID.rawValue,
//                        name: categories.categoryIDs
//                    )
//                }
            }
        }
        .padding([.leading], 16)
    }
}

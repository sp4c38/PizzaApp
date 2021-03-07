//
//  CategorySelection.swift
//  PizzaTech
//
//  Created by Léon Becker on 06.03.21.
//

import SwiftUI

struct CategorySelectionButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    init(isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.white)
            .padding([.top, .bottom], 4)
            .padding([.leading, .trailing], 8)
            
            .background(isSelected ? Color.red : Color.blue)
            .cornerRadius(6)
            
            .shadow(radius: 3)
            .animation(.easeInOut)
    }
}

struct CategorySelectionButton: View {
    @EnvironmentObject var catalogService: CatalogService
    
    let id: CategoryID
    let name: String
    
    var isCurrentlySelected: Bool {
        catalogService.categorySelection == id
    }
    
    init(id: CategoryID) {
        self.id = id
        self.name = id.name
    }
    
    var body: some View {
        Button(action: {
            onCategorySelection()
        }) {
            Text(name)
        }
        .buttonStyle(CategorySelectionButtonStyle(isSelected: isCurrentlySelected))
    }
    
    func onCategorySelection() {
        catalogService.setCategorySelection(to: id)
    }
}

struct CategorySelection: View {
    @EnvironmentObject var catalogService: CatalogService
    var categories: Categories {
        catalogService.catalog!.categories
    }
    
    let gridColumns: [GridItem] = [
        GridItem(.adaptive(minimum: 100), spacing: 20, alignment: .center)
    ]
    
    var body: some View {
        LazyVGrid(columns: gridColumns, alignment: .center, spacing: 10) {
            ForEach(categories.categoryID, id: \.identification) { categoryID in
                CategorySelectionButton(id: categoryID)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding([.leading, .trailing], 16)
    }
}

struct CategorySelectin_Preview: PreviewProvider {
    static var previews: some View {
        CategorySelection()
            .modifier(PizzaTechServices())
    }
}

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
            .animation(.easeInOut(duration: 0.2))
    }
}

struct CategorySelection: View {
    @EnvironmentObject var catalogService: CatalogService
    
    let gridColumns: [GridItem] = [
        GridItem(.adaptive(minimum: 100), spacing: 20, alignment: .center)
    ]
    
    var body: some View {
        LazyVGrid(columns: gridColumns, alignment: .center, spacing: 10) {
            ForEach(catalogService.catalog!.categories.categoryID, id: \.id) { categoryID in
                Button(action: {
                    catalogService.categorySelection = categoryID
                }) {
                    Text(categoryID.name)
                }
                .buttonStyle(CategorySelectionButtonStyle(isSelected: catalogService.categorySelection == categoryID))
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

//
//  CurrentCategory.swift
//  PizzaTech
//
//  Created by Léon Becker on 06.03.21.
//

import SwiftUI

struct SelectedCategory: View {
    @EnvironmentObject var catalogService: CatalogService
    var selection: CategoryID {
        catalogService.categorySelection
    }
    var categories: Categories {
        catalogService.catalog!.categories
    }
    
    var body: some View {
        VStack {
            if selection == .pizza {
                CategoryItemCollection(items: categories.pizza.items)
            }
        }
    }
}

struct CategoryItemNameModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .font(.subheadline.weight(.bold))
            .multilineTextAlignment(.center)
            .padding(4)
    }
}

struct CategoryItemCollection<T: CatalogGeneralItem>: View {
    let items: [T]
    
    init(items: [T]) {
        self.items = items
    }
    
    var body: some View {
        VStack {
            ForEach(items, id: \.id) { item in
                VStack(spacing: 0) {
                    Image(item.imageName)
                        .resizable()
                        .scaledToFit()

                    Text(item.name)
                        .modifier(CategoryItemNameModifier())
                }
                .background(
                    Color(hue: 0.9916, saturation: 0.9689, brightness: 0.8824)
                )
                .cornerRadius(10)
                .shadow(radius: 4)
            }
        }
    }
}

struct CurrentCategory_Previews: PreviewProvider {
    static var previews: some View {
        SelectedCategory()
            .modifier(PizzaTechServices())
    }
}

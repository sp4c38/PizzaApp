//
//  CategoryItemsCollection.swift
//  PizzaApp
//
//  Created by Léon Becker on 04.02.21.
//

import SwiftUI

func packItems<Item: CatalogItem>(_ items: [Item]) -> [[Item]] {
    //
    // Example
    //   in: [Pizza1, Pizza2, Pizza3, Pizza4, Pizza5]
    //  out: [[Pizza1, Pizza2], [Pizza3, Pizza4], [Pizza5]]


    var output = [[Item]]()
    var currentIndex = 0

    for _ in 1...Int((Double(items.count) / 2).rounded(.up)) {
        if !(currentIndex + 1 > (items.count - 1)) {
            output.append([items[currentIndex], items[currentIndex + 1]])
        } else {
            output.append([items[currentIndex]])

        }

        currentIndex += 2
    }

    return output
}

struct CategoryItemsPairCollection<Item: CatalogItem>: View {
    let items: [Item]
    
    init(_ items: [Item]) {
        self.items = items
    }
    
    var body: some View {
        HStack(spacing: 20) {
            //                NavigationLink(destination: PizzaInfoView(info: catalog.info, pizza: items[0])) {
            CollectionView(item: items[0])
            
            // }


//                NavigationLink(destination: PizzaInfoView(info: catalog.info, pizza:  items[1])) {
                    CollectionView(item: items[1])
//                }

        }.padding()
    }
}

struct CategoryItemsCollection<Item: CatalogItem>: View {
    @Binding var categorySelection: Int
    
    @State var packedItems = [[Item]]()
    
    func makePackedItems(for categorySelection: Int) {
        var selectedItems = [Item]()
        if categorySelection == 0 {
            selectedItems = catalog.pizzas as! [Item]
        }
        let packedItems = packItems(selectedItems)
        self.packedItems = packedItems
    }
    
    var body: some View {
        VStack {
            ForEach(packedItems, id: \.self) { items in
                HStack(spacing: 20) {
                    CategoryItemsPairCollection(items)
                }
                .padding()
            }
        }
        .onAppear {
            makePackedItems(for: categorySelection)
        }
        .onChange(of: categorySelection) { newCategorySelection in
            makePackedItems(for: newCategorySelection)
        }
    }
}

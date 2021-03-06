//
//  ItemInfoView.swift
//  PizzaApp
//
//  Created by Léon Becker on 13.08.20.
//

import SwiftUI
import UIKit

enum DishHints {
    case vegetarian, vegan, spicy
}

class ItemDisplayInfo {
    let id: Int32
    let name: String
    let image: Image
    let imageName: String
    let ingredientDescription: String
    let dishHints: [DishHints]
    
    let useSinglePrice: Bool
    var singlePrice: Double = 0
    var prices = [Double]()
    
    init(
        id: Int32,
        name: String,
        imageName: String,
        ingredientDescription: String,
        dishHints: [DishHints],
        prices: [Double]
    ) {
        self.id = id
        self.name = name
        image = Image(imageName)
        self.imageName = imageName
        self.ingredientDescription = ingredientDescription
        self.dishHints = dishHints
        useSinglePrice = false
        self.prices = prices
    }
    
    init(
        id: Int32,
        name: String,
        imageName: String,
        ingredientDescription: String,
        dishHints: [DishHints],
        singlePrice: Double
    ) {
        self.id = id
        self.name = name
        image = Image(imageName)
        self.imageName = imageName
        self.ingredientDescription = ingredientDescription
        self.dishHints = dishHints
        useSinglePrice = true
        self.singlePrice = singlePrice
    }
}

struct ItemInfoView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var selectedSizeIndex = 1
    
    var info: [String: [String]]
    var item: ItemDisplayInfo

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
                    item.image
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(6)
                        .padding(.leading, -4) // Needed to hide the corner Radius when the image covers the total width of the screen
                        .padding(.trailing, -4)
                        .padding(.bottom, 7)
                    
                }
                    
            HStack(spacing: 5) {
                Text(item.name)
                    .font(.system(size: 40))
                    .bold()
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                    .padding(.top, 4)
            }

            Text(item.ingredientDescription)
                .font(.callout)
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
                .shadow(radius: 5)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hue: 1.0000, saturation: 1.0000, brightness: 0.4824))
                .padding(.bottom, 20)

            
            VStack {
                if !item.useSinglePrice {
                    PricesView(item, catalog.info, $selectedSizeIndex)
                } else {
                    SinglePriceView(item)
                }
            }
            .padding(.bottom, 40)
    
            Spacer()
            
            Button(action: {
                let newCartItem = ShoppingCartItem(context: managedObjectContext)
                newCartItem.pizzaId = item.id
                newCartItem.name = item.name
                newCartItem.pictureName = item.imageName
                if item.useSinglePrice {
                    newCartItem.price = item.singlePrice
                } else {
                    newCartItem.price = item.prices[selectedSizeIndex]
                }
                newCartItem.sizeIndex = Int16(selectedSizeIndex)

                do {
                    try managedObjectContext.save()
                    print("Added item to shopping cart.")
                } catch {
                    print("Error when trying to save a new Cart item. Error: \(error)")
                }

            }) {
                Text("Zum Warenkorb hinzufügen")
                    .bold()
            }
            .buttonStyle(AddToCartButton())
            .padding(.bottom, 15)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
            HStack {
                if item.dishHints.contains(.vegetarian) {
                    IsVegetarianView()
                }
                if item.dishHints.contains(.vegan) {
                    IsVeganView()
                }
                if item.dishHints.contains(.spicy) {
                    IsSpicyView()
                }
            }
        )
    }
}

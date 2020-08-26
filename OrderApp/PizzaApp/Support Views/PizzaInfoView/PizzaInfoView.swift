//
//  PizzaInfo.swift
//  PizzaApp
//
//  Created by Léon Becker on 13.08.20.
//

import SwiftUI
import UIKit

struct PizzaInfoView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var selectedSizeIndex = 1
    
    var info: [String: [String]]
    var pizza: Pizza

    var body: some View {
        VStack(spacing: 0) {
            pizza.image
                .resizable()
                .scaledToFit()
                .padding(.leading, -4) // Needed to hide the corner Radius when the image covers the total width of the screen
                .padding(.trailing, -4)
                .padding(.bottom, 10)
            
            Text(pizza.name)
                .font(.system(size: 40))
                .bold()
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.bottom, 15)

            Text(pizza.ingredientDescription)
                .font(.callout)
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
                .shadow(radius: 5)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hue: 1.0000, saturation: 1.0000, brightness: 0.4824))
                .padding(.bottom, 25)

            PricesView(info: info, pizza: pizza, selectedSizeIndex: $selectedSizeIndex)
                .padding(.bottom, 25)
    
            Button(action: {
                let newCartItem = ShoppingCartItem(context: managedObjectContext)
                newCartItem.pizzaId = pizza.id
                newCartItem.name = pizza.name
                newCartItem.pictureName = pizza.imageName
                newCartItem.price = pizza.prices[selectedSizeIndex]
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
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PizzaInfo_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PizzaInfoView(info: PizzaCatalog.info, pizza: PizzaCatalog.pizzas[0])
        }
    }
}

//
//  PizzaInfo.swift
//  PizzaApp
//
//  Created by Léon Becker on 13.08.20.
//

import SwiftUI

struct PizzaInfoView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var info: [String: [String]]
    var pizza: Pizza

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text(pizza.name)
                        .font(.system(size: 50))
                        .bold()
                        .padding(.leading, 16)
                        .padding(.trailing, 16)
                        .padding(.top, 20)
                        .multilineTextAlignment(.center)

                    pizza.image
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(20)

                    Text(pizza.ingredientDescription)
                        .font(.callout)
                        .bold()
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                        .shadow(radius: 5)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hue: 1.0000, saturation: 1.0000, brightness: 0.4824))
                        .padding(.bottom, 10)

                    PricesView(info: info, pizza: pizza)

                    Button(action: {
                        let newCartItem = ShoppingCartItem(context: managedObjectContext)
                        newCartItem.name = pizza.name
                        newCartItem.pictureName = pizza.imageName
                        newCartItem.sizeIndex = 0
                        
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
                    .padding(.bottom, 10) // Padding to the button because of the notch
                }
            }
        }
    }
}

//struct PizzaInfo_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            PizzaInfoView(info: PizzaData.info, pizza: PizzaData.pizzas[1]!)
//            PizzaInfoView(info: PizzaData.info, pizza: PizzaData.pizzas[1]!)
//                .preferredColorScheme(.dark)
//        }
//    }
//}

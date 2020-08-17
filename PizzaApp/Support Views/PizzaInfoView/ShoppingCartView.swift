//
//  ShoppingCartView.swift
//  PizzaApp
//
//  Created by Léon Becker on 15.08.20.
//

import SwiftUI

struct ShoppingCartView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: ShoppingCartItem.entity(),
        sortDescriptors: []
    ) var shoppingCart: FetchedResults<ShoppingCartItem>
    
    @State var continueToCheckout: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            
            if shoppingCart.isEmpty {
                
                Spacer()
                Text("Dein Warenkorb ist noch leer. Suche dir eine Pizza aus! 🍕")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(30)
                Spacer()
            } else if !shoppingCart.isEmpty {
                if !continueToCheckout {
                    ScrollView {
                        VStack {
                            ForEach(shoppingCart) { storedPizza in
                                PizzaCollectionShoppingCartView(shoppingCartItem: storedPizza)
                                    .padding(.leading, 40)
                                    .padding(.trailing, 40)
                                    .padding(.top, 20)
                                    .transition(.moveAndFade)
                            }
                        }
                    }
                
                    Button(action: {
                        withAnimation {
                            continueToCheckout = true
                        }
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "eurosign.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 30)
                                .foregroundColor(Color.white)
                            Text("Zur Kasse")
                                .bold()
                                .font(.title2)
                                .foregroundColor(Color.white)
                        }
                    }
                    .buttonStyle(CheckoutButtonStyle())
                    .transition(.moveAndFade)
                }
            }
        }.navigationBarTitle("Warenkorb", displayMode: .inline)
    }
}

//
//  ShoppingCartView.swift
//  PizzaApp
//
//  Created by Léon Becker on 15.08.20.
//

import SwiftUI

struct ShoppingCartView: View {
    @FetchRequest(
        entity: ShoppingCartItem.entity(),
        sortDescriptors: []
    ) var shoppingCart: FetchedResults<ShoppingCartItem>
    
    @State var continueToCheckout: Bool = false
    
    var body: some View {
        return VStack(spacing: 0) {
            
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
                            }
                        }
                        .padding(.bottom, 15)
                    }
                
                    NavigationLink(destination: CheckoutView()) {
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
                    .buttonStyle(CheckoutButtonStyle()) // Also applies to NavigationLink
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                }
            }
        }
        .navigationBarTitle("Warenkorb", displayMode: .inline)
        .animation(.easeInOut(duration: 0.3))
    }
}

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
            
            if !shoppingCart.isEmpty {
                if !continueToCheckout {
                    ScrollView {
                        VStack(spacing: 0) {
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
            } else {
                Spacer()
                
                VStack(spacing: 30) {
                    Image(systemName: "multiply.circle")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.red)
                        .frame(width: 50, height: 50)
                    
                    Text("Dein Warenkorb ist noch leer.\n\nSuche dir eine Pizza aus! 🍕")
                        .font(.title)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(7)
                .overlay(RoundedRectangle(cornerRadius:7).stroke(Color.black, lineWidth: 1))
                .padding(28)
                .shadow(radius: 6)
                
                Spacer()
            }
        }
        .navigationBarTitle("Warenkorb", displayMode: .inline)
        .animation(.easeInOut(duration: 0.3))
    }
}

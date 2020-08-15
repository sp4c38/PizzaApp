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
        entity: ShoppingCart.entity(),
        sortDescriptors: []
    ) var shoppingCart: FetchedResults<ShoppingCart>
    
    @State var continueToCheckout: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            HStack {
                Text("Warenkorb")
                    .bold()
                    .font(.title)
                Image(systemName: "cart.fill")
            }
            
            if shoppingCart.isEmpty {
                Spacer()
                Text("Dein Warenkorb ist noch leer. Suche dir eine Pizza aus! 🍕")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(30)
                Spacer()
            } else if !shoppingCart.isEmpty {
                ScrollView(.vertical, showsIndicators: true) {
                    ForEach(shoppingCart) { pizza in
                        PizzaCollectionShoppingCartView(shoppingCartItem: pizza)
                            .padding(.leading, 40)
                            .padding(.trailing, 40)
                            .padding(.top, 20)
                    }
                    
                    if !continueToCheckout {
                        Button(action: {
                            continueToCheckout = true
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
                        .padding(.top, 30)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .padding(.top, 40)
    }
}

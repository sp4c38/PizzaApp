//
//  PizzaCollection.swift
//  PizzaApp
//
//  Created by Léon Becker on 14.08.20.
//

import SwiftUI

struct PizzaCollectionShoppingCartView: View {
    // A single pizza box which is shown in the shopping cart view
    
    var shoppingCartItem: ShoppingCartItem
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(shoppingCartItem.pictureName)
                .resizable()
                .scaledToFit()
                .cornerRadius(7)
                .border(Color.white, width: 2)
                .padding(.top, 2)
                .padding(.leading, 2)
                .padding(.trailing, 2)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Pizza \(shoppingCartItem.name)")
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                    .shadow(radius: 4)
                    .padding(.bottom, 10)
            
                HStack {
                    Text("Größe:")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Text(PizzaData.info["sizes"]![Int(shoppingCartItem.sizeIndex)])
                        .font(.headline)
                }
                
                HStack {
                    Text("Preis:")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Text("\(shoppingCartItem.price .description) €")
                        .font(.headline)
                }
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.bottom, 10)
        }
        .foregroundColor(Color.white)
        .background(Color(hue: 0.9916, saturation: 0.9689, brightness: 0.8824))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white, lineWidth: 4)
        )
        .shadow(radius: 5)
        .padding(2)
    }
}

struct PizzaCollectionView: View {
    // A single pizza box which is shown on the home/root screen
    
    var pizza: Pizza
    
    var body: some View {
        VStack {
            pizza.image
                .resizable()
                .scaledToFit()
                .cornerRadius(7)
                .border(Color.white, width: 2)
                .padding(.top, 2)
                .padding(.leading, 2)
                .padding(.trailing, 2)
            
            Text(pizza.name)
                .font(.subheadline)
                .bold()
                .multilineTextAlignment(.center)
                .shadow(radius: 4)
                .padding(.bottom, 10)
                .padding(.trailing, 5)
        }
        .foregroundColor(Color.white)
        .background(Color(hue: 0.9916, saturation: 0.9689, brightness: 0.8824))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white, lineWidth: 4)
        )
        .shadow(radius: 5)
        .padding(2)
    }
}

struct PizzaCollection_Previews: PreviewProvider {
    static var previews: some View {
        PizzaCollectionView(pizza: PizzaData.pizzas[0])
            .frame(width: 150, height: 150)
    }
}

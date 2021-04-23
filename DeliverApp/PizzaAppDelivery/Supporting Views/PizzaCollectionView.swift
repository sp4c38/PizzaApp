//
//  PizzaCollectionView.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 25.08.20.
//

import SwiftUI

struct PizzaCollectionView: View {
    var pizza: DisplayPizza
    var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "de_De")
        
        return numberFormatter
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
                Image(pizza.imageName)
                    .resizable()
                    .scaledToFit()
                
                VStack(alignment: .trailing) {
                    if pizza.vegetarian {
                        IsVegetarianView()
                    }
                    if pizza.vegan {
                        IsVeganView()
                    }
                    if pizza.spicy {
                        IsSpicyView()
                    }
                }.padding()
            }
            
            VStack(alignment: .center, spacing: 5) {
                VStack(alignment: .center, spacing: 0) {
                    Text("Pizza \(pizza.name)")
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                        .shadow(radius: 4)
                    
                    Text(pizza.ingredientDescription)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .shadow(radius: 4)
                }.padding(.bottom, 10)
                
                HStack {
                    Text("Größe:")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Text(pizzaCatalog.info["sizes"]![Int(pizza.sizeIndex)])
                        .font(.headline)
                }
                
                HStack {
                    Text("Preis:")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Text(numberFormatter.string(from: NSNumber(value: pizza.price))!)
                        .font(.headline)
                }
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.bottom, 10)
            .padding(.top, 10)
            .background(Color(hue: 0.9916, saturation: 0.9689, brightness: 0.8824))
            .foregroundColor(Color.white)
        }
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white, lineWidth: 7)
        )
        .shadow(radius: 5)
    }
}

struct PizzaCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        PizzaCollectionView(pizza: DisplayPizza(name: "Margherita", imageName: "margherita", sizeIndex: 0, price: 6.99, ingredientDescription: "mit Pizzasoße und echtem Gouda", vegetarian: true, vegan: false, spicy: false))
    }
}

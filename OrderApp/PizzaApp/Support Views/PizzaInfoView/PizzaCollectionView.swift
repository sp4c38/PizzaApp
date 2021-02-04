//
//  PizzaCollection.swift
//  PizzaApp
//
//  Created by Léon Becker on 14.08.20.
//

import SwiftUI
import CoreData

struct DisplayPizzaCollectionView: View {
    var pizza: DisplayPizza
    var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "de_De")
        
        return numberFormatter
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Image(pizza.imageName)
                .resizable()
                .scaledToFit()
            
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
                    Text(catalog.info["sizes"]![Int(pizza.sizeIndex)])
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

struct PizzaCollectionShoppingCartView: View {
    // A single pizza box which is shown in the shopping cart view
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var shoppingCartItem: ShoppingCartItem
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Spacer()
                
                HStack(spacing: 60) {
                    Button(action: {
                        managedObjectContext.delete(shoppingCartItem)
                        do {
                            try managedObjectContext.save()
                        } catch {
                            print("Error occurred saving the removal of a item from the ShoppingCart. \(error)")
                        }
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: "cart.badge.minus")
                                .padding(11)
                                .background(
                                    Circle()
                                        .foregroundColor(Color.white)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.black, lineWidth: 2)
                                        )
                                        .shadow(radius: 9)
                                )
                            
                            Text("Entfernen")
                                .minimumScaleFactor(0.9) // Prevent Text from being not shown completely on certain settings
                                .font(.subheadline)
                        }
                    }
                    
                    Button(action: {
                        
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: "highlighter")
                                .padding(11)
                                .background(
                                    Circle()
                                        .foregroundColor(Color.white)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.black, lineWidth: 2)
                                        )
                                        .shadow(radius: 9)
                                )
                            
                            Text("Verfeinern")
                                .minimumScaleFactor(0.9)
                                .font(.subheadline)
                        }
                    }
                }
                Spacer()
            }
            .frame(maxHeight: 70)
            .padding(5)
            
            VStack(alignment: .center, spacing: 0) {
                Image(shoppingCartItem.pictureName)
                    .resizable()
                    .scaledToFit()
                
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
                        Text(catalog.info["sizes"]![Int(shoppingCartItem.sizeIndex)])
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
}

struct PizzaCollectionView: View {
    // A single pizza box which is shown on the home/root screen
    
    var pizza: Pizza
    
    var body: some View {
        VStack(spacing: 0) {
            pizza.image
                .resizable()
                .scaledToFit()
                .overlay(Rectangle().stroke(Color.white, lineWidth: 5))

            Text(pizza.name)
                .font(.subheadline)
                .bold()
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.9)
                .shadow(radius: 4)
                .frame(maxWidth: .infinity)
                .padding(8)
                .foregroundColor(Color.white)
                .background(Color(hue: 0.9916, saturation: 0.9689, brightness: 0.8824))
        }
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 13)
                .stroke(Color.white, lineWidth: 3)
        )
        .shadow(radius: 5)
    }
}

struct PizzaCollection_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 20) {
            PizzaCollectionView(pizza: catalog.pizzas[0])
            PizzaCollectionView(pizza: catalog.pizzas[0])
        }.padding()
    }
}

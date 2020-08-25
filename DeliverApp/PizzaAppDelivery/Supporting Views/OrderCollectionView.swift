//
//  PizzaCollection.swift
//  PizzaApp
//
//  Created by Léon Becker on 14.08.20.
//

import SwiftUI
import CoreData

struct OrderCollectionView: View {
    // A single pizza box which is shown in the shopping cart view
    
    var order: SingleOrder
    var pizzaOrderedNumber: Int {
        order.pizzasOrdered.count
    }
    
    var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.none
        return numberFormatter
    }
    
    var body: some View {
        return VStack(alignment: .center) {
            HStack {
                Image("pizzaIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
                Text("\(pizzaOrderedNumber) \((pizzaOrderedNumber == 1) ? "Pizza" : "Pizzen")")
                    .bold()
                    .font(.system(size: 40))
                    .padding()
            }
            
                            
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 5) {
                    HStack(spacing: 11) {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundColor(Color.white)
                        
                        Text("Name:")
                            .font(.title3)
                            .bold()
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("\(order.firstname) \(order.lastname)")
                    }.minimumScaleFactor(0.9)
                }
                .shadow(radius: 5)
                
                HStack(spacing: 5) {
                    HStack(spacing: 11) {
                        Image(systemName: "mappin.and.ellipse")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundColor(Color.white)
                        
                        Text("Addresse:")
                            .font(.title3)
                            .bold()
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(order.street)
                        Text("\(order.city) (\(numberFormatter.string(from: NSNumber(value: order.postalCode))!))")
                    }.minimumScaleFactor(0.9)
                }
                .shadow(radius: 5)
                
                HStack(spacing: 5) {
                    HStack(spacing: 11) {
                        Image(systemName: "eurosign.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundColor(Color.white)
                        
                        Text("Preis aller Pizzen:")
                            .font(.title3)
                            .bold()
                    }

                    Spacer()
                    
                    Text("12 €")
                        .font(.headline)
                }
                .shadow(radius: 5)
            }
        }
        .padding(.leading, 20)
        .padding(.trailing, 20)
        .padding(.bottom, 15)
        .padding(.top, 15)
        .background(Color(hue: 0.9916, saturation: 0.9689, brightness: 0.8824))
        .foregroundColor(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white, lineWidth: 7)
        )
        .shadow(radius: 5)
    }
}

struct OrderCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        OrderCollectionView(order: SingleOrder(firstname: "Firstname", lastname: "Lastname", street: "Apple Park Way", postalCode: 95014, city: "Cupertino", paymentMethod: 0, pizzasOrdered: [SinglePizzaOrdered(pizzaId: 1, sizeIndex: 0)]))
    }
}

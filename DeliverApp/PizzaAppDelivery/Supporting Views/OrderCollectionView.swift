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
        numberFormatter.minimumIntegerDigits = 5
        return numberFormatter
    }
    
    var allPizzasOrdered = [DisplayPizza]()

    var priceFormatter: NumberFormatter
    
    init(order: SingleOrder) {
        self.order = order
        var unresolvedPizzas = [(Int32, Int8)]()
        
        priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .currency
        priceFormatter.locale = Locale(identifier: "de_De")
        
        for orderedPizza in order.pizzasOrdered {
            unresolvedPizzas.append((orderedPizza.pizzaId, orderedPizza.sizeIndex))
        }
        
        for pizza in pizzaCatalog.pizzas {
            if unresolvedPizzas.contains(where: {$0.0 == pizza.id}) {
                for orderedPizza in unresolvedPizzas.filter({$0.0 == pizza.id}) {
                    let newDisplayPizza = DisplayPizza(
                        name: pizza.name,
                        imageName: pizza.imageName,
                        sizeIndex: orderedPizza.1,
                        price: pizza.prices[Int(orderedPizza.1)],
                        ingredientDescription: pizza.ingredientDescription,
                        vegetarian: pizza.vegetarian,
                        vegan: pizza.vegan,
                        spicy: pizza.spicy
                    )
                        
                    allPizzasOrdered.append(newDisplayPizza)
                }
            }
        }
    }
    
    func calculateAllPizzaPrices(pizzas: [DisplayPizza]) -> Double {
        var allPrice = 0.00
        
        for each in pizzas {
            allPrice += each.price
        }
        
        return allPrice
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
                    
                    Text(priceFormatter.string(from: NSNumber(value: calculateAllPizzaPrices(pizzas: allPizzasOrdered)))!)
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
        OrderCollectionView(order: SingleOrder(order_id: 29, firstname: "Firstname", lastname: "Lastname", street: "Apple Park Way", postalCode: 95014, city: "Cupertino", paymentMethod: 0, pizzasOrdered: [SinglePizzaOrdered(pizzaId: 1, sizeIndex: 0)]))
    }
}

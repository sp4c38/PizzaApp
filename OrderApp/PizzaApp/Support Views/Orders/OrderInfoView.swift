//
//  OrderInfoView.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 25.08.20.
//

import SwiftUI

struct DisplayPizza: Hashable {
    // struct holding information about a single ordered pizza to display it with all information (not just the id and size index) which is required for displaying a ordered pizza

    var name: String
    var imageName: String
    var sizeIndex: Int8
    var price: Double
    var ingredientDescription: String
}

struct OrderInfoView: View {
    var order: FetchedResults<Order>.Element
    var decodedPizzaData: StoredOrderData
    
    var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.none
        return numberFormatter
    }
    
    var unresolvedPizzas = [(Int32, Int8)]()
    var allPizzasOrdered = [DisplayPizza]()
    
    init(order: FetchedResults<Order>.Element, decodedPizzaData: StoredOrderData) {
        self.order = order
        self.decodedPizzaData = decodedPizzaData
        
        for orderedPizza in decodedPizzaData.allStoredPizzas {
            unresolvedPizzas.append((orderedPizza.pizzaId, Int8(orderedPizza.pizzaSizeIndex)))
        }
  
        for pizza in catalog.pizzas {
            if unresolvedPizzas.contains(where: {$0.0 == pizza.id}) {
                for orderedPizza in unresolvedPizzas.filter({$0.0 == pizza.id}) {
                    let newDisplayPizza = DisplayPizza(
                        name: pizza.name,
                        imageName: pizza.imageName,
                        sizeIndex: orderedPizza.1,
                        price: pizza.prices[Int(orderedPizza.1)],
                        ingredientDescription: pizza.ingredientDescription)
                    
                    allPizzasOrdered.append(newDisplayPizza)
                }
            }
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center, spacing: 30) {
                Image("LoginPizzaImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130)
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Vorname: ")
                            .bold()
                        Spacer()
                        Text(order.firstname)
                            .minimumScaleFactor(0.9)
                    }
                    
                    HStack {
                        Text("Nachname: ")
                            .bold()
                        Spacer()
                        Text(order.lastname)
                            .minimumScaleFactor(0.9)
                    }
                    
                    HStack {
                        Text("Straße: ")
                            .bold()
                        Spacer()
                        Text(order.street)
                            .minimumScaleFactor(0.9)
                    }
                    
                    
                    HStack {
                        Text("Ort (PLZ): ")
                            .bold()
                        Spacer()
                        Text("\(order.city) (\(numberFormatter.string(from: NSNumber(value: order.postalCode))!))")
                            .minimumScaleFactor(0.9)
                    }
                    
                    HStack {
                        Text("Bezahloption: ")
                            .bold()
                        Spacer()
                        
                        if order.paymentMethod == 1 {
                            Text("Vor Ort in Bar")
                                .minimumScaleFactor(0.9)
                        } else if order.paymentMethod == 2 {
                            Text("Mit Karte")
                                .minimumScaleFactor(0.9)
                        }
                    }
                    
                    NavigationLink(destination: InvoiceView(order: order, allPizzas: allPizzasOrdered)) {
                        Text("Rechnung einsehen")
                            .bold()
                        Spacer()
                    }
                    
                    
                    VStack {
                        return ForEach(allPizzasOrdered, id: \.self) { pizza in
                            return DisplayPizzaCollectionView(pizza: pizza)
                                .padding(.leading, 16)
                                .padding(.trailing, 16)
                                .padding(.bottom, 15)
                        }
                    }.padding(.top, 25)
                }
            }
            .padding()
            .navigationBarTitle("Pizza Lieferung")
        }
    }
}

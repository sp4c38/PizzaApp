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
    var vegetarian: Bool
    var vegan: Bool
    var spicy: Bool
}

struct OrderInfoView: View {
    @Environment(\.keychainStore) var keychainStore
    @EnvironmentObject var username: UsernameData
    
    var order: SingleOrder
    var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.none
        return numberFormatter
    }
    
    var unresolvedPizzas = [(Int32, Int8)]()
    var allPizzasOrdered = [DisplayPizza]()
    
    init(order: SingleOrder) {
        self.order = order

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
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Image("LoginPizzaImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130)
                    .padding(.top, 7)
                
                NavigationLink(destination: HomeView()) {
                    Button(action: {
                        deleteOrder(orderId: order.order_id, username: username.username, keychainStore: keychainStore)
                    }) {
                       Text("Bestellung abschließen")
                            .foregroundColor(Color.white)
                            .font(.title2)
                    }
                    .padding()
                    .buttonStyle(CompleteOrderButtonStyle())
                    .padding(.bottom, 0)
                }
        
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
                        ForEach(allPizzasOrdered, id: \.self) { pizza in
                            PizzaCollectionView(pizza: pizza)
                                .padding(.leading, 16)
                                .padding(.trailing, 16)
                                .padding(.bottom, 15)
                        }
                    }.padding(.top, 20)
                }
                .padding()
                .navigationBarTitle("Pizza Lieferung")
            }
        }
    }
}

struct OrderInfoView_Previews: PreviewProvider {
    static var previews: some View {
        OrderInfoView(order: SingleOrder(order_id: 29, firstname: "Firstname", lastname: "Lastname", street: "Apple Park Way", postalCode: 95014, city: "Cupertino", paymentMethod: 1, pizzasOrdered: [SinglePizzaOrdered(pizzaId: 1, sizeIndex: 0)]))
    }
}

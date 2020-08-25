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
    var order: SingleOrder
    var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.none
        return numberFormatter
    }
    var resolvePizzaIds = [Int32]()
    var allPizzasOrderedResolved = [DisplayPizza]()
    
    init(order: SingleOrder) {
        self.order = order
        
        for pizza in order.pizzasOrdered {
            resolvePizzaIds.append(pizza.pizzaId)
        }
        
        for pizza in pizzaCatalog.pizzas {
            if resolvePizzaIds.contains(pizza.id) {
                let newDisplayPizza = DisplayPizza(
                    name: pizza.name,
                    imageName: pizza.imageName,
                    sizeIndex: 0,
                    price: pizza.prices[0],
                    ingredientDescription: pizza.ingredientDescription)
                
                allPizzasOrderedResolved.append(newDisplayPizza)
            }
        }
    }
    
    var body: some View {
        ScrollView {
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
                    
                    ForEach(allPizzasOrderedResolved, id: \.self) { pizza in
                        Text(String(pizza.name))
                    }
                }
            }
            .padding()
            .navigationBarTitle("Pizza Lieferung")
        }
    }
}

struct OrderInfoView_Previews: PreviewProvider {
    static var previews: some View {
        OrderInfoView(order: SingleOrder(firstname: "Firstname", lastname: "Lastname", street: "Apple Park Way", postalCode: 95014, city: "Cupertino", paymentMethod: 1, pizzasOrdered: [SinglePizzaOrdered(pizzaId: 1, sizeIndex: 0)]))
    }
}

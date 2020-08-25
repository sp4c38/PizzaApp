//
//  InvoiceView.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 25.08.20.
//

import SwiftUI

struct InvoiceView: View {
    var order: SingleOrder
    var allPizzas: [DisplayPizza]
    var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "de_De")
        
        return numberFormatter
    }
    
    var totalPrice: Double {
        var allPrice = 0.00
        
        for each in allPizzas {
            allPrice += each.price
        }
        return allPrice
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 40) {
            Text("Danke für Ihren Einkauf bei Paulos Pizza")
                .bold()
                .font(.title)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            VStack {
                ForEach(allPizzas, id: \.self) { pizza in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(pizza.name)
                            Spacer()
                            Text(numberFormatter.string(from: NSNumber(value: pizza.price))!)
                                .foregroundColor(Color.gray)
                        }
                        Divider()
                    }
                }
                
                HStack {
                    Text("Bezahloption: ")
                    Spacer()
                
                    if order.paymentMethod == 1 {
                        Text("Vor Ort in Bar")
                            .minimumScaleFactor(0.9)
                    } else if order.paymentMethod == 2 {
                        Text("Mit Karte")
                            .minimumScaleFactor(0.9)
                    }
                }.padding(.bottom, 5)
                
                HStack {
                    Text("Summe: ")
                        .font(.title2)
                    Spacer()
                    Text(numberFormatter.string(from: NSNumber(value: totalPrice))!)
                        .font(.title2)
                }
                
                Spacer()
            }
        }
        .navigationBarTitle("Rechnung")
        .navigationBarTitleDisplayMode(.inline)
        .padding()
    }
}

struct InvoiceView_Previews: PreviewProvider {
    static var previews: some View {
        InvoiceView(order: SingleOrder(firstname: "Firstname", lastname: "Lastname", street: "Street name", postalCode: 29392, city: "City name", paymentMethod: 1, pizzasOrdered: []), allPizzas: [DisplayPizza(name: "Margherita", imageName: "margherita", sizeIndex: 0, price: 6.99, ingredientDescription: "mit Pizzasoße und echtem Gouda"), DisplayPizza(name: "4 Käse", imageName: "4käse", sizeIndex: 0, price: 10.99, ingredientDescription: "mit Pizzasoße, Hirtenkäse, Mozzarella, Cheddar und echtem Gouda")])
    }
}

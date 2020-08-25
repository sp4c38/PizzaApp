//
//  OrderInfoView.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 25.08.20.
//

import SwiftUI

struct OrderInfoView: View {
    var order: SingleOrder
    var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.none
        return numberFormatter
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

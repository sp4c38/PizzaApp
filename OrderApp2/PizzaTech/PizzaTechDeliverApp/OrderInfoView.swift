//
//  OrderInfoView.swift
//  PizzaTechDeliverApp
//
//  Created by Léon Becker on 12.06.21.
//

import SwiftUI

struct OrderInfoView: View {
    @State var percentFinished: Double = 0
    var order: Order
    
    var body: some View {
        VStack {
            Text("\(Int(percentFinished))%")
            HStack {
                Text("0%")
                Slider(value: $percentFinished, in: 0.0...100.0, step: 1) { newValue in
                    if !newValue {
                        print("Changed to \(percentFinished).")
                    }
                }
                Text("100%")
            }
        }
        .onAppear {
            // percentFinished = order.percentFinished
        }
    }
}

struct OrderInfoView_Previews: PreviewProvider {
    static var previews: some View {
        OrderInfoView(order: Order(details: OrderDetails(city: "Arnsdorf", first_name: "Léon", last_name: "Becker", postal_code: "19383", street: "Karswaldsiedlung 19"), items: [OrderedItem(item_id: 1, order_id: 1, quantity: 1, unit_price: 12.9)]))
    }
}

//
//  OrderPreview.swift
//  PizzaTechDeliverApp
//
//  Created by Léon Becker on 12.06.21.
//

import SwiftUI

func convertCountToString(count: Int) -> String {
    if count == 1 {
        return "Eine Ware bestellt."
    } else if count > 1 {
        return "\(count) Waren bestellt."
    } else {
        return "Keine Waren bestellt."
    }
}

struct OrderPreview: View {
    @State var isActive = false
    var order: Order
    
    var body: some View {
        NavigationLink(destination: OrderInfoView(order: order), isActive: $isActive) {
            VStack(alignment: .trailing) {
                Text(order.details.street)
                Text("\(order.details.postal_code) \(order.details.city)")
                Text(convertCountToString(count: order.items.count))
            }
            .onTapGesture {
                isActive = true
            }
        }
    }
}

struct OrderPreview_Previews: PreviewProvider {
    static var previews: some View {
        OrderPreview(order: Order(details: OrderDetails(city: "Arnsdorf", first_name: "Léon", last_name: "Becker", postal_code: "19383", street: "Karswaldsiedlung 19"), items: [OrderedItem(item_id: 1, order_id: 1, quantity: 1, unit_price: 12.9)]))
    }
}

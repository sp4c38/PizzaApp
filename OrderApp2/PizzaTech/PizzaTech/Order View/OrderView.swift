//
//  OrderView.swift
//  PizzaTech
//
//  Created by Léon Becker on 11.06.21.
//

import SwiftUI

struct OrderView: View {
    @State var orderSending = false
    @State var orderSuccessful = false
    @FetchRequest(entity: OrderedItem.entity(), sortDescriptors: []) var orderedItems: FetchedResults<OrderedItem>
    
    var body: some View {
        VStack {
            ForEach(orderedItems) { orderedItem in
                HStack {
                    Text(String(orderedItem.item_id))
                    Text(String(orderedItem.price))
                    Text(String(orderedItem.quantity))
                }
            }
            Spacer()
            Button(action: { orderItems() }) {
                Text("Order")
            }
        }
    }
    
    func orderItems() {
        var orderRequestItems = [OrderRequestItem]()
        for item in orderedItems {
            let newRequestItem = OrderRequestItem(item_id: Int(item.item_id), price: item.price, quantity: Int(item.quantity))
            orderRequestItems.append(newRequestItem)
        }
        
        let newOrderRequest = OrderRequest(first_name: "L", last_name: "B", street: "Ka", city: "A", postal_code: "4", items: orderRequestItems)
        
        var request = URLRequest(url: URL(string: "https://www.space8.me:7392/order/make/")!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        
        let jsonEncoder = JSONEncoder()
        let encodedNewOrderRequest = try! jsonEncoder.encode(newOrderRequest)
        
        request.httpMethod = "POST"
        request.httpBody = encodedNewOrderRequest

        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            orderSuccessful = true
            print("Order successful.")
        })
        orderSending = true
        task.resume()
    }
}

struct OrderRequestItem: Encodable {
    var item_id: Int
    var price: Double
    var quantity: Int
}

struct OrderRequest: Encodable {
    var first_name: String
    var last_name: String
    var street: String
    var city: String
    var postal_code: String
    var items: [OrderRequestItem]
}

struct OrderView_Previews: PreviewProvider {
    static var previews: some View {
        OrderView()
    }
}

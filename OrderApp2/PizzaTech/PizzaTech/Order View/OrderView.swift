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
        let details = OrderRequestDetails(first_name: "L", last_name: "B", street: "K", city: "A", postal_code: "4")
        
        let newOrderRequest = OrderRequest(items: orderRequestItems, details: details)
        
        let jsonEncoder = JSONEncoder()
        let encodedNewOrderRequest = try! jsonEncoder.encode(newOrderRequest)
        
        var request = URLRequest(url: URL(string: "https://www.space8.me:7392/order/make/")!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Content-Type": "application/json"]
        request.httpBody = encodedNewOrderRequest

        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if error == nil {
                print("Error: \(error).")
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("Status \(httpResponse.statusCode)")
                print("Order should be successful.")
            }

            orderSuccessful = true
        }).resume()
        orderSending = true
    }
}

struct OrderRequestItem: Encodable {
    var item_id: Int
    var price: Double
    var quantity: Int
}

struct OrderRequestDetails: Encodable {
    var first_name: String
    var last_name: String
    var street: String
    var city: String
    var postal_code: String
}

struct OrderRequest: Encodable {
    var items: [OrderRequestItem]
    var details: OrderRequestDetails
}

struct OrderView_Previews: PreviewProvider {
    static var previews: some View {
        OrderView()
    }
}

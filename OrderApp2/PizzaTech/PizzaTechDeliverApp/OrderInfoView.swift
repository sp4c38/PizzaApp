//
//  OrderInfoView.swift
//  PizzaTechDeliverApp
//
//  Created by Léon Becker on 12.06.21.
//

import SwiftUI

struct OrderInfoView: View {
    @State var percentageUpdatable = true
    @State var percentFinished: Double = 0
    var order: Order
    
    var body: some View {
        VStack {
            Text("\(Int(percentFinished))%")
            HStack {
                Text("0%")
                Slider(value: $percentFinished, in: 0.0...100.0, step: 1) { newValue in
                    if !newValue {
                        print("Changed order percentage to \(percentFinished).")
                        updateOrderPercentage(newPercentage: Int(percentFinished))
                    }
                }
                .opacity(percentageUpdatable ? 1 : 0.8)
                .disabled(percentageUpdatable ? false : true)
            }
        }
        .onAppear {
            percentFinished = Double(order.details.order_progress)
        }
    }
    
    func updateOrderPercentage(newPercentage: Int) {
        let verificationToken = "21d8209f415ee72f31cb9311938e93414f972db568ba148382eeec3cf2c5ea00"
        var request = URLRequest(url: URL(string: "https://www.space8.me:7392/order/update/progress/")!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        request.allHTTPHeaderFields = ["Authorization": "Bearer \(verificationToken)", "Content-Type": "application/json"]
        request.httpBody = """
        {"order_id": \(order.items[0].order_id), "new_progress": \(newPercentage)}
        """.data(using: .utf8)
        request.httpMethod = "POST"
        percentageUpdatable = false
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                percentageUpdatable = true
            }
        }
        task.resume()
    }
}

struct OrderInfoView_Previews: PreviewProvider {
    static var previews: some View {
        OrderInfoView(order: Order(details: OrderDetails(city: "Arnsdorf", first_name: "Léon", last_name: "Becker", postal_code: "19383", street: "Karswaldsiedlung 19", order_progress: 40), items: [OrderedItem(item_id: 1, order_id: 1, quantity: 1, unit_price: 12.9)]))
    }
}

//
//  ContentView.swift
//  PizzaTechDeliverApp
//
//  Created by Léon Becker on 12.06.21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var catalogService: CatalogService
    @EnvironmentObject var ordersService: OrdersService
    
    @State var downloadingOrders = false
    @State var orderInfoOpen = false
    
    let timer = Timer.publish(every: TimeInterval(30), on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ScrollView {
                if ordersService.orders != nil {
                    ForEach(ordersService.orders!.orders, id: \.items[0].order_id) { order in
                        OrderPreview(orderInfoOpen: $orderInfoOpen, order: order)
                    }
                }
                
                Spacer()
            }
            .onReceive(timer) { _ in downloadOrdersManager() }
            .onAppear { downloadOrdersManager() }
            .navigationTitle("Bestellungen")
            .navigationBarItems(trailing:
                                    Button(action: { downloadOrdersManager(force: true) }) {
                                        Image(systemName: "arrow.clockwise")
                                            .resizable()
                                            .font(.title2)
                                    }
            )
        }
    }
    
    func downloadOrdersManager(force: Bool = false) {
        if !orderInfoOpen || force == true {
            DispatchQueue.global(qos: .userInitiated).async {
                let downloadedOrders = downloadOrders()
                DispatchQueue.main.async { ordersService.orders = downloadedOrders }
            }
        }
    }
    
    func downloadOrders() -> Orders? {
        let verificationToken = "21d8209f415ee72f31cb9311938e93414f972db568ba148382eeec3cf2c5ea00"
        var request = URLRequest(url: URL(string: "https://www.space8.me:7392/order/get_all/")!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        request.allHTTPHeaderFields = ["Authorization": "Bearer \(verificationToken)"]
        let semaphore = DispatchSemaphore(value: 0)
        var orders: Orders? = nil
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let decoder = JSONDecoder()
            orders = try! decoder.decode(Orders.self, from: data!)
            semaphore.signal()
        }
        downloadingOrders = true
        print("Started downloading orders.")
        task.resume()
        semaphore.wait()
        print("Finished downloading orders.")
        downloadingOrders = false
        return orders
    }
}

struct OrderDetails: Decodable {
    var city: String
    var first_name: String
    var last_name: String
    var postal_code: String
    var street: String
    var order_progress: Int
}

struct OrderedItem: Decodable {
    var item_id: Int
    var order_id: Int
    var quantity: Int
    var unit_price: Float
}

struct Order: Decodable {
    var details: OrderDetails
    var items: [OrderedItem]
}

struct Orders: Decodable {
    var orders: [Order]
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(OrdersService())
            .environmentObject(CatalogService())
    }
}

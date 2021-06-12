//
//  OrderView.swift
//  PizzaTech
//
//  Created by Léon Becker on 11.06.21.
//

import SwiftUI

//struct OrderedItemD {
//    var quantity = 2
//    var price = 19.99
//}

struct SingleOrderedItemView: View {
    let orderedItem: OrderedItem
    let item: CatalogGeneralItem?
    
    let numberFormatter = { () -> NumberFormatter in
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.decimalSeparator = ","
        return numberFormatter
    }()
    
    var body: some View {
        if item != nil {
            HStack(alignment: .top) {
                Image(item!.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 210)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 0) {
                    Text(item!.name)
                        .bold()
                        .font(.title2)
                        .padding(.bottom, 3)
                    
                    Text("\(orderedItem.quantity)x")
                    Spacer()
                    Text("\(numberFormatter.string(for: orderedItem.price)!) €")
                        .bold()
                        .font(.title2)
                }
                .padding(.top, 15)
                .padding(.bottom, 10)
                .padding(.trailing, 15)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .cornerRadius(10)
            .padding([.leading, .trailing])
            .fixedSize(horizontal: false, vertical: true)
            .shadow(radius: 10)
        } else {
            VStack {}
        }
    }
}


struct OrderView: View {
    @EnvironmentObject var catalogService: CatalogService
    @State var orderSending = false
    @State var orderSuccessful = false
    @FetchRequest(entity: OrderedItem.entity(), sortDescriptors: []) var orderedItems: FetchedResults<OrderedItem>
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 30) {
                    ForEach(orderedItems) { orderedItem in
                        SingleOrderedItemView(orderedItem: orderedItem, item: getCatalogItem(order: orderedItem))
                    }
                }
            }
            Spacer()
            Button(action: { orderItems() }) {
                Text("Order")
            }
        }
    }
    
    func getCatalogItem(order: OrderedItem) -> CatalogGeneralItem? {
        guard let catalog = catalogService.catalog else {
            return nil
        }
        let categories = catalog.categories
        let item_id = order.item_id
        var foundItem: CatalogGeneralItem? = nil
        for item in categories.pizza.items { if item.id == item_id { foundItem = item } }
        for item in categories.burger.items { if item.id == item_id { foundItem = item } }
        for item in categories.iceDessert.items { if item.id == item_id { foundItem = item } }
        for item in categories.salad.items { if item.id == item_id { foundItem = item } }
        for item in categories.drink.items { if item.id == item_id { foundItem = item } }
        for item in categories.pasta.items { if item.id == item_id { foundItem = item } }
        if foundItem != nil {
            print("Found item: \(foundItem).")
        }
        return foundItem
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
                print("Error: \(String(describing: error)).")
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
            .environmentObject(CatalogService())
//        SingleOrderedItemView(orderedItem: OrderedItemD(), item: PizzaItem(id: 10, name: "Margheritta", imageName: "margherita", prices: [1,2,34], ingredientDescription: "mit Pizzasauce", speciality: FoodCharacteristics(vegetarian: true, vegan: true, spicy: false)))
    }
}

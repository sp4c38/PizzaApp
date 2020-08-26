//
//  OrdersView.swift
//  PizzaApp
//
//  Created by Léon Becker on 20.08.20.
//

import SwiftUI

struct SingleOrderCollection: View {
    var order: FetchedResults<Order>.Element
    var allStoredOrders: FetchedResults<Order>
    let jsonDecoder = JSONDecoder()
    
    var decodedPizzasOrdered = StoredOrderData(allStoredPizzas: [])
    
    init(order: FetchedResults<Order>.Element, allStoredOrders: FetchedResults<Order>) {
        self.order = order
        self.allStoredOrders = allStoredOrders
        
        do {
            decodedPizzasOrdered = try jsonDecoder.decode(StoredOrderData.self, from: order.pizzasOrdered)
        } catch {
           fatalError("Error decoding the ordered pizzas from a stored order.")
        }
    }
    
    var body: some View {
        VStack {
            NavigationLink(destination: OrderInfoView(order: order, decodedPizzaData: decodedPizzasOrdered)) {
                OrderCollectionView(order: order, decodedPizzaData: decodedPizzasOrdered)
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
            }
        }
    }
}

struct OrdersView: View {
    @FetchRequest(
        entity: Order.entity(),
        sortDescriptors: []) var allStoredOrders: FetchedResults<Order>

    var body: some View {
        VStack {
            if allStoredOrders.count > 0 {
                Text("Pizza Bestellungen")
                    .bold()
                    .font(.title)
                    .padding(.top, 16)
                
                ScrollView(showsIndicators: true) {
                    VStack(spacing: 30) {
                        ForEach(allStoredOrders) { order -> SingleOrderCollection in
                            return SingleOrderCollection(order: order, allStoredOrders: allStoredOrders)
                        }
                    }
                    .padding(.top, 15)
                    .padding(.bottom, 15)
                }
                
            } else {
                Spacer()
                VStack(spacing: 30) {
                    Image(systemName: "multiply.circle")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.red)
                        .frame(width: 50, height: 50)
                    
                    Text("Du hast noch\n keine Bestellungen")
                        .font(.title)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(7)
                .overlay(RoundedRectangle(cornerRadius:7).stroke(Color.black, lineWidth: 1))
                .padding(40)
                .shadow(radius: 6)
                
                Spacer()
            }
        }
        .navigationBarTitle((allStoredOrders.count == 0) ? "Bestellungen" : "")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct OrdersView_Previews: PreviewProvider {
    static var previews: some View {
        OrdersView()
    }
}

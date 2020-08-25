//
//  HomeView.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 24.08.20.
//

import CoreData
import SwiftUI

struct HomeView: View {
    @Environment(\.keychainStore) var keychainStore
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var username: UsernameData
    
    @State var orders: OrderData?
    
    var body: some View {
        return ScrollView() {
            Text("Pizza Bestellungen")
                .bold()
                .font(.title)
            
            Button(action: {
                orders = downloadOrders(username: username.username, keychainStore: keychainStore)
            }) {
                Text("Bestellungen herunterladen")
            }
            
            if orders != nil {
                ForEach(orders!.orders, id: \.self) { order in
                    Text(order.street)
                }
            }
            
            Spacer()
            
            
        }
        .padding()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            HomeView()
        }
    }
}

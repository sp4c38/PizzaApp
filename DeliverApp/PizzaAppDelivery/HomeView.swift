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
        NavigationView {
            VStack {
                Text("Pizza Bestellungen")
                    .bold()
                    .font(.title)
                    .padding()
                
                Button(action: {
                    print()
                    orders = downloadOrders(username: username.username, keychainStore: keychainStore)
                }) {
                    Text("Bestellungen aktualisieren")
                        .bold()
                        .foregroundColor(Color.white)
                }.buttonStyle(RefreshButtonStyle())
                
                if orders != nil && ((orders != nil) ? !(orders!.orders.isEmpty) : false) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .center, spacing: 20) {
                            ForEach(orders!.orders, id: \.self) { order in
                                NavigationLink(destination: OrderInfoView(order: order)) {
                                    OrderCollectionView(order: order)
                                        .padding(.leading, 20)
                                        .padding(.trailing, 20)
                                }
                            }
                        }.padding(.top, 20)
                    }
                } else {
                    Spacer()
                    Text("🍕 Es gibt momentan keine Bestellungen.")
                        .font(.title)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            HomeView()
        }
    }
}

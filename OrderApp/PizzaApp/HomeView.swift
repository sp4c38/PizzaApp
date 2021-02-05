//
//  HomeView.swift
//  PizzaApp
//
//  Created by Léon Becker on 13.08.20.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var orderProperty: OrderProperty
    
    @State var selectedCategory: Int = 0
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                if orderProperty.showOrderSuccessful {
                    OrderSuccessful()
                }
                
                Button(action: {}) {
                    NavigationLink(destination: OrdersView()) {
                        VStack {
                            Text("Alle Bestellungen")
                                .font(.headline)
                                .foregroundColor(Color.white)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .buttonStyle(AllOrdersButton())
                
                CategorySelection(selectedCategory: $selectedCategory)
                
                VStack {
                    if selectedCategory == 0 {
                        CategoryItemsCollection<Pizza>()
                            .transition(.opacity)
                    } else if selectedCategory == 1 {
                        CategoryItemsCollection<IceAndDessert>()
                    }
                }
                .animation(.easeInOut)
            }
            .navigationBarTitle("Pizza Paulo")
            .navigationBarItems(trailing:
                NavigationLink(destination: ShoppingCartView().environment(\.managedObjectContext, managedObjectContext)) {
                    HStack {
                        Text("Warenkorb")
                        Image(systemName: "cart")
                    }
                }
            )
        }
        .navigationBarHidden(true) // hides the navigation bar when comming from the checkout view
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(OrderProperty())
    }
}

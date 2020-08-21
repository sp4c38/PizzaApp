//
//  HomeView.swift
//  PizzaApp
//
//  Created by Léon Becker on 13.08.20.
//

import SwiftUI
import CoreData

func packPizzas() -> [[Pizza]] {
    //
    // Example
    //   in: [Pizza1, Pizza2, Pizza3, Pizza4, Pizza5]
    //  out: [[Pizza1, Pizza2], [Pizza3, Pizza4], [Pizza5]]


    var output = [[Pizza]]()
    var currentIndex = 0

    for pizza in PizzaData.pizzas {
        currentIndex += 1
        if !(currentIndex + 1 > PizzaData.pizzas.count) {
            output.append([pizza, PizzaData.pizzas[currentIndex + 1]])
            currentIndex += 2
        } else {
            output.append([pizza])
            return output
        }
    }

    return output
}

struct HomeView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var orderProperty: OrderProperty
    
    var packedPizzas: [[Pizza]] = packPizzas()
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                if orderProperty.showOrderSuccessful {
                    OrderSuccessful()
                }
                
                NavigationLink(destination: OrdersView()) {
                    Button(action: {
                    
                    }) {
                        Text("Alle Bestellungen")
                            .font(.headline)
                            .foregroundColor(Color.white)
                    }
                }
                .padding()
                .buttonStyle(AllOrdersButton())
                
                ForEach(packedPizzas, id: \.self) { pizza in
                    HStack {
                        if pizza.count > 1 {
                            NavigationLink(destination: PizzaInfoView(info: PizzaData.info, pizza: pizza[0])) {
                                PizzaCollectionView(pizza: pizza[0])
                            }

                            NavigationLink(destination: PizzaInfoView(info: PizzaData.info, pizza:  pizza[1])) {
                                PizzaCollectionView(pizza: pizza[1])
                            }
                        } else if !(pizza.count > 1) {
                            NavigationLink(destination: PizzaInfoView(info: PizzaData.info, pizza:  pizza[0])) {
                                PizzaCollectionView(pizza: pizza[0])
                            }
                            .padding(.leading, 70)
                            .padding(.trailing, 70)
                        }

                    }.padding()
                }
            }
            .navigationBarTitle("Pizzen")
            .navigationBarItems(trailing:
                NavigationLink (destination: ShoppingCartView().environment(\.managedObjectContext, managedObjectContext)) {
                    HStack {
                        Text("Warenkorb")
                        Image(systemName: "cart")
                    }
                }
            )
            .configureNavigationBar()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(OrderProperty())
    }
}

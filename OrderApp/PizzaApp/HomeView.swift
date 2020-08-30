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
    print(PizzaCatalog.pizzas)
    print(PizzaCatalog.pizzas.count)
    for _ in 1...(PizzaCatalog.pizzas.count / 2) {
        if !(currentIndex + 1 >= PizzaCatalog.pizzas.count) {
            output.append([PizzaCatalog.pizzas[currentIndex], PizzaCatalog.pizzas[currentIndex + 1]])
        } else {
            output.append([PizzaCatalog.pizzas[currentIndex]])

            return output
        }

        currentIndex += 2
    }
    
    return output
}

struct HomeView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var orderProperty: OrderProperty
    
    var packedPizzas = packPizzas()
    
    var body: some View {
        print(packedPizzas)
        return NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                if orderProperty.showOrderSuccessful {
                    OrderSuccessful()
                }
                
                
                Button(action: {

                }) {
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
                
                ForEach(packedPizzas, id: \.self) { pizza in
                    HStack(spacing: 20) {
                        if pizza.count > 1 {
                            NavigationLink(destination: PizzaInfoView(info: PizzaCatalog.info, pizza: pizza[0])) {
                                PizzaCollectionView(pizza: pizza[0])
                            }

                            NavigationLink(destination: PizzaInfoView(info: PizzaCatalog.info, pizza:  pizza[1])) {
                                PizzaCollectionView(pizza: pizza[1])
                            }
                        } else if !(pizza.count > 1) {
                            NavigationLink(destination: PizzaInfoView(info: PizzaCatalog.info, pizza:  pizza[0])) {
                                PizzaCollectionView(pizza: pizza[0])
                            }
                            .padding(.leading, 78)
                            .padding(.trailing, 78)
                        }

                    }.padding()
                }
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

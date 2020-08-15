//
//  HomeView.swift
//  PizzaApp
//
//  Created by Léon Becker on 13.08.20.
//

import SwiftUI
import CoreData

func packPizzas() -> [[Pizza]] {
    //   This function takes an array with Pizzas and packages them to double-packs. The last pack can happen to be just an array with a single item like:
    // Example
    //   in: [Pizza1, Pizza2, Pizza3, Pizza4, Pizza5]
    //  out: [[Pizza1, Pizza2], [Pizza3, Pizza4], [Pizza5]]

    
    var currentIndex: Int = 0
    var output =  [[Pizza]]()
    
    for _ in PizzaData.pizzas {
        if !(currentIndex + 1 > PizzaData.pizzas.count - 1) {
            output.append([PizzaData.pizzas[currentIndex], PizzaData.pizzas[currentIndex + 1]])
            currentIndex += 2
        } else {
            output.append([PizzaData.pizzas[currentIndex]])
            
            return output
        }
    }
    
    return output
}


struct HomeView: View {
    @State var showShoppingCart: Bool = false
    @Environment(\.managedObjectContext) var managedObjectContext
    var packedPizzas: [[Pizza]] = packPizzas()
    
    var body: some View {
        return VStack {
            NavigationView {
                ScrollView(.vertical, showsIndicators: false) {
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
                .padding(.top, 10)
                .navigationBarTitle("Pizzen")
                .navigationBarItems(trailing:
                    Button(action: {
                        showShoppingCart = true
                    }) {
                        HStack {
                            Text("Warenkorb")
                            Image(systemName: "cart")
                        }
                        .padding(.top, 10)
                        .padding(.trailing, 10)
                    })
            }
            .sheet(isPresented: $showShoppingCart) {
                ShoppingCartView().environment(\.managedObjectContext, managedObjectContext) // Needed to parse environment objects to sheets
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

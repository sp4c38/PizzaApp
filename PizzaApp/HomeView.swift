//
//  HomeView.swift
//  PizzaApp
//
//  Created by Léon Becker on 13.08.20.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView() {
            List {
                ForEach(PizzaData.pizzas, id: \.self) { pizza in
                    NavigationLink(destination: PizzaInfoView(info: PizzaData.info, pizza: pizza)) {
                        Text(pizza.name)
                    }
                }
            }
            .navigationBarTitle("Pizza")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

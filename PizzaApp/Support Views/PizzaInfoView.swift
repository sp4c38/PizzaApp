//
//  PizzaInfo.swift
//  PizzaApp
//
//  Created by Léon Becker on 13.08.20.
//

import SwiftUI

struct PizzaInfoView: View {
    var pizza: Pizza
    
    var body: some View {
        Text(pizza.name)
    }
}

struct PizzaInfo_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

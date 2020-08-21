//
//  ContentView.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 21.08.20.
//

import SwiftUI

struct ContentView: View {
    
    init() {
        TestSomeStuff()
    }
    
    var body: some View {
        LoginView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

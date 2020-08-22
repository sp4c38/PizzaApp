//
//  ContentView.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 21.08.20.
//

import CoreData
import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: UserData.entity(), sortDescriptors: [])
    var orders: FetchedResults<UserData>
    
    var hasAccount: Bool = true
    
    var body: some View {
        if hasAccount {
            Text("has account")
        } else if !hasAccount {
            LoginView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

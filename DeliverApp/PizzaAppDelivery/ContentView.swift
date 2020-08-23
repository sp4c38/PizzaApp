//
//  ContentView.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 21.08.20.
//

import CoreData
import SwiftUI


struct ContentView: View {
    @Environment(\.keychainStore) var keychainStore
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: UserData.entity(),
        sortDescriptors: []) var usernamesResult: FetchedResults<UserData>
    
    var hasAccount: String? {
        verifyAccountStored(usernames: usernamesResult, keychainStore: keychainStore)
    }
    
    var body: some View {
        return VStack {
            if hasAccount != nil {
                Text("Account Found")
            } else {
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

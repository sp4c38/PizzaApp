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
    
    var body: some View {
        return ScrollView() {
            Text("Pizza Bestellungen")
                .bold()
                .font(.title)
            
            Spacer()
            Text(username.username)
        }
        .padding()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

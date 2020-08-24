//
//  HomeView.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 24.08.20.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.keychainStore) var keychainStore
    @EnvironmentObject var username: UsernameData
    @FetchRequest(fetchRequest: BlogIdea.allIdeasFetchRequest()) var fetchedUserData: FetchedResults<BlogIdea>
    
    
    var cake = NSFetchRequest()
//
//    var orders = Bool()
//
//    init() {
//        self.orders = downloadOrders(username: username.username, keychainStore: keychainStore)
//    }
    
    var body: some View {
        print(fetchedUserData)
        return ScrollView() {
            Text("Pizza Bestellungen")
                .bold()
                .font(.title)
            
            Spacer()
        }
        .padding()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

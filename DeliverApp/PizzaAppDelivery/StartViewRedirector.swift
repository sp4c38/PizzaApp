//
//  ContentView.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 21.08.20.
//

import CoreData
import SwiftUI

class UsernameData: ObservableObject {
    var username: String = ""
    
    func changeUsername(username: String) {
        self.username = username
    }
}

struct ContentView: View {
    // Redirects to either the LoginView if the stored account isn't valid or no account was logged-in yet.
    // Otherwise redirects to the main view.
    
    @Environment(\.keychainStore) var keychainStore
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: UserData.entity(),
        sortDescriptors: []) var usernamesResult: FetchedResults<UserData>

    var username = UsernameData()

    var body: some View {
        let checkUsername = checkGetUsernameStored(usernames: usernamesResult)
        var hasAccount = Bool()
        
        if checkUsername != nil {
            username.changeUsername(username: checkUsername!) // Save the username in a class to prevent reading CoreData over and over
            // Only check if the account stored is valid if there is a username stored. Otherwise can skip the step to check if the login data is valid if no username is stored.
            hasAccount = verifyAccountStored(usernameStored: username.username, keychainStore: keychainStore)
        } else {
            hasAccount = false
        }
        
        return VStack {
            if hasAccount {
                HomeView()
                    .environmentObject(username)
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

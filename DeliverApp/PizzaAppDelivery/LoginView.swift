//
//  LoginView.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 21.08.20.
//

import CoreData
import SwiftUI

struct LoginView: View {
    @Environment(\.keychainStore) var keychainStore
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var keyboardResponder = KeyboardResponder() // Takes care of moving the view up accordingly when the keyboard is presented
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State var errorWhenCheckingLogin: Bool = false
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 40) {
                HStack(spacing: 20) {
                    Image("LoginPizzaImage")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width / 3)
                    
                    Text("Herzlich Willkommen!")
                        .bold()
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.9)
                }
                
                VStack(alignment: .leading, spacing: 40) {
                    Text("Anmelden")
                        .bold()
                        .font(.largeTitle)
                    
                    VStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Benutzername:")
                                .bold()
                        
                            TextField("Benutzername", text: $username)
                                .disableAutocorrection(true)
                                .padding(7)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                                .id(1) // Need to set an id because otherwise the button would be disabled due to a later .shadow
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Passwort:")
                                .bold()
                                .font(.headline)
                        
                            SecureField("Passwort", text: $password)
                                .disableAutocorrection(true)
                                .padding(7)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                                .id(2) // Need to set an id because otherwise the button would be disabled due to a later following .shadow
                        }
                    }
                        
                        
                    Button(action: {
                        if password != "" && username != "" {
                            // Save the account which was successfully logged-in
                            let checkLoginSuccessful = checkAndSaveAccount(username: username, password: password, managedObjectContext: managedObjectContext, keychainStore: keychainStore)
                           
                            if !checkLoginSuccessful {
                                errorWhenCheckingLogin = true
                            }
                        }
                    }) {
                        Text("Login")
                            .bold()
                            .font(.title2)
                    }
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(9)
                    .background(Color.blue)
                    .cornerRadius(7)
                }
                .foregroundColor(Color.black)
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(Color.white)
                )
                .shadow(radius: 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .offset(y: -keyboardResponder.keyboardHeight * 0.6)
        }
        .background(
            Image("LoginScreenBackground")
                .resizable()
                .scaledToFill()
                .blur(radius: 5)
        )
        .ignoresSafeArea()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

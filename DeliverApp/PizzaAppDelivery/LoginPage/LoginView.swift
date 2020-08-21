//
//  LoginView.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 21.08.20.
//

import SwiftUI

struct LoginView: View {
    @State var username: String = ""
    @State var password: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 40) {
                HStack(spacing: 15) {
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
                
                VStack(spacing: 20) {
                    Text("Anmelden")
                        .bold()
                        .font(.title2)
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Benutzername:")
                            Text("Passwort: ")
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            TextField("Benutzername", text: $username)
                                .padding(7)
                                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.black, lineWidth: 2))
                            TextField("Passwort", text: $password)
                                .padding(7)
                                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.black, lineWidth: 2))
                        }
                    }
                    
                    Button(action: {}) {
                        Text("Login")
                    }
                }
                .foregroundColor(Color.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.black, lineWidth: 2)
                        .background(Color.red.cornerRadius(5))
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(
                Image("LoginScreenBackground")
                    .resizable()
                    .scaledToFill()
            )
            .ignoresSafeArea()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

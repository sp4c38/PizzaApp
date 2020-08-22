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
                    
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Benutzername:")
                                .bold()
                        
                            TextField("Benutzername", text: $username)
                                .padding(7)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Passwort:")
                                .bold()
                                .font(.headline)
                        
                            SecureField("Passwort", text: $password)
                                .padding(7)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                        }
                    }
                    
                    
                    Button(action: {
                        
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
                    .animation(.spring())
                }
                .foregroundColor(Color.black)
                .padding(30)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(Color.white)
                )
                .shadow(radius: 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(
                Image("LoginScreenBackground")
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 5)
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

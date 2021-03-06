//
//  MainActionsView.swift
//  PizzaTech
//
//  Created by Léon Becker on 05.03.21.
//

import SwiftUI

struct MainActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .multilineTextAlignment(.center)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            
            .background(Color.red)
            .cornerRadius(10)
            .shadow(color: .gray, radius: 5, x: -1, y: 2)
    }
}

struct MainActionsView: View {
    var body: some View {
        HStack(spacing: 20) {
            Button(action: {
                
            }) {
                HStack {
                    Image(systemName: "cart")
                    Text("Warenkorb")
                }
            }
            .buttonStyle(MainActionButtonStyle())
            
            Button(action: {
                
            }) {
                HStack {
                    Text("Bestellungen")
                    Image(systemName: "archivebox")
                }
            }
            .buttonStyle(MainActionButtonStyle())
        }
        .padding([.leading, .trailing], 16)
    }
}

struct MainActionsView_Previews: PreviewProvider {
    static var previews: some View {
        MainActionsView()
    }
}

//
//  HomeActionView.swift
//  PizzaTech
//
//  Created by Léon Becker on 05.03.21.
//

import SwiftUI

struct AllOrdersButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            
            .background(Color.red)
            .cornerRadius(10)
            .shadow(radius: 7)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 2)
            )
            .padding([.leading, .trailing], 16)
    }
}

struct HomeActionView: View {

    var body: some View {
        VStack {
            Button(action: {
                
            }) {
                Text("Alle Bestellungen")
                    .font(.headline)
            }
            .buttonStyle(AllOrdersButtonStyle())
        }
    }
}

struct HomeActionView_Previews: PreviewProvider {
    static var previews: some View {
        HomeActionView()
    }
}

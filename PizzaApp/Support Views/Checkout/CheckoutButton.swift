//
//  CheckoutButton.swift
//  PizzaApp
//
//  Created by Léon Becker on 15.08.20.
//

import SwiftUI

struct CheckoutButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.black, lineWidth: 2)
            )
            .shadow(radius: 5)
    }
}

struct BuyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .shadow(radius: 7)
            .scaleEffect(configuration.isPressed ? CGFloat(1.3) : 1.0)
            .rotationEffect(.degrees(configuration.isPressed ? 0.0 : 0))
    }
}

struct CheckoutButton_Previews: PreviewProvider {
    static var previews: some View {
        Button(action: {}) {
            HStack(spacing: 15) {
                Image(systemName: "eurosign.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 30)
                    .foregroundColor(Color.white)
                Text("Zur Kasse")
                    .bold()
                    .font(.title2)
                    .foregroundColor(Color.white)
            }
        }.buttonStyle(CheckoutButtonStyle())
    }
}

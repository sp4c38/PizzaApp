//
//  AddToCartButton.swift
//  PizzaApp
//
//  Created by Léon Becker on 14.08.20.
//

import SwiftUI

struct AddToCartButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.black)
            .padding(18)
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .background(Color.white)
            .cornerRadius(40)
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(
                        Color(hue: 0.9916, saturation: 0.9689, brightness: 0.8824), lineWidth: 5)
            )
            .shadow(radius: 7)
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.2))
    }
}

//
//  CheckoutButton.swift
//  PizzaApp
//
//  Created by Léon Becker on 15.08.20.
//

import SwiftUI

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        let insertion = AnyTransition.opacity
            .combined(with: .move(edge: .trailing))
        let removal = AnyTransition.opacity
            .combined(with: .move(edge: .trailing))
        
        return AnyTransition.asymmetric(insertion: insertion, removal: removal)
    }
}

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
            .shadow(radius: 3)
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

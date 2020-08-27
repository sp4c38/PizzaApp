//
//  CompleteOrderButton.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 27.08.20.
//

import SwiftUI

struct CompleteOrderButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(7)
            .background(Color.green)
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.black, lineWidth: 2)
            )
            .shadow(radius: 5)
    }
}

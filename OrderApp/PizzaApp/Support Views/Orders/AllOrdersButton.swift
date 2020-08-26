//
//  AllOrdersButton.swift
//  PizzaApp
//
//  Created by Léon Becker on 20.08.20.
//

import SwiftUI

struct AllOrdersButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.red)
            .cornerRadius(10)
            .shadow(radius: 7)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 2)
            )
    }
}

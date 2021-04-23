//
//  RefreshButtonStyle.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 25.08.20.
//

import SwiftUI

struct RefreshButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 4)
            )
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .shadow(radius: 3)
    }
}

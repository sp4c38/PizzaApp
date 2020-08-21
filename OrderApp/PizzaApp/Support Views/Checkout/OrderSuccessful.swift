//
//  OrderSuccessful.swift
//  PizzaApp
//
//  Created by Léon Becker on 20.08.20.
//

import SwiftUI

struct OrderSuccessful: View {
    var body: some View {
        VStack {
            VStack(spacing: 15) {
                Text("Vielen Dank!")
                    .bold()
                    .font(.title)
                    .foregroundColor(Color.white)
                
                Text("😊")
                    .font(.largeTitle)
            
                Text("Ihre Bestellung war erfolgreich.")
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .foregroundColor(Color.white)
                    .brightness(3)
            }
            .padding(15)
            .background(Color(hue: 1.0000, saturation: 1.0000, brightness: 0.8588))
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 2))
        }
        .shadow(radius: 5)
        .padding(.top, 12)
    }
}

struct OrderSuccessful_Previews: PreviewProvider {
    static var previews: some View {
        OrderSuccessful()
    }
}

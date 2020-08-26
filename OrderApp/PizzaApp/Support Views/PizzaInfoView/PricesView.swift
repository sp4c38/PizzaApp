//
//  PricesView.swift
//  PizzaApp
//
//  Created by Léon Becker on 14.08.20.
//

import SwiftUI

struct PricesView: View {
    var info: [String: [String]]
    var pizza: Pizza

    var body: some View {
        VStack {
            HStack {
                Text("Größen:")
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 10)
                Spacer()
            }
            
            ForEach(info["sizes"]!, id: \.self) { size in
                let index = info["sizes"]!.firstIndex(of: size)
                
                HStack {
                    Text(size)
                    Spacer()
                    Text("\(String(pizza.prices[index!])) €")
                }
                .padding(.bottom, 12)
            }
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(Color.white)
        .font(.headline)
        .padding()
        .background(Color(hue: 0.9916, saturation: 0.9689, brightness: 0.8824))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 5)
                .foregroundColor(Color.white)
        )
        .shadow(radius: 10)
        .padding()
    }
}

struct PricesView_Previews: PreviewProvider {
    static var previews: some View {
        PizzaInfoView(info: PizzaCatalog.info, pizza: PizzaCatalog.pizzas[0])
    }
}

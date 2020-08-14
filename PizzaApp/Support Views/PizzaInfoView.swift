//
//  PizzaInfo.swift
//  PizzaApp
//
//  Created by Léon Becker on 13.08.20.
//

import SwiftUI

struct PizzaInfoView: View {
    var info: [String: [String]]
    var pizza: Pizza
    
    var body: some View {
        VStack {
            pizza.image
                .resizable()
                .scaledToFit()
            
            Text(pizza.name)
                .font(.system(size: 50))
                .bold()
                .padding()
        
            VStack {
                HStack {
                    Text("Preise:")
                        .font(.title2)
                        .bold()
                        .padding(.bottom, 10)
                    Spacer()
                }
                
                Divider()
                
                ForEach(info["sizes"]!, id: \.self) { size in
                    let index = info["sizes"]!.firstIndex(of: size)!
                    HStack {
                        Text(size)
                        Spacer()
                        Text("\(String(pizza.prices[index])) €")
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
                RoundedRectangle(cornerRadius: 3)
                    .stroke(lineWidth: 5)
                    .foregroundColor(Color.white)
            )
            .shadow(radius: 10)
            .padding()
            
            Spacer()
        }
    }
}

struct PizzaInfo_Previews: PreviewProvider {
    static var previews: some View {
        PizzaInfoView(info: PizzaData.info, pizza: PizzaData.pizzas[0])
    }
}

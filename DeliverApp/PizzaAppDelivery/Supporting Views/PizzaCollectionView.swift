//
//  PizzaCollection.swift
//  PizzaApp
//
//  Created by Léon Becker on 14.08.20.
//

import SwiftUI
import CoreData

struct PizzaOrderCollectionView: View {
    // Single View which is shows all important details about a pizza order at a glance
    
    var body: some View {
        VStack(alignment: .center) {
            Image("margerita")
                .resizable()
                .scaledToFit()
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Pizza")
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                    .shadow(radius: 4)
                    .padding(.bottom, 10)
            
                HStack {
                    Text("Größe:")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Text("Freddy")//PizzaData.info["sizes"]![Int(shoppingCartItem.sizeIndex)])
                        .font(.headline)
                }
                
                HStack {
                    Text("Preis:")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Text("10.99 €")//"\(shoppingCartItem.price .description) €")
                        .font(.headline)
                }
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.bottom, 10)
            .padding(.top, 10)
            .background(Color(hue: 0.9916, saturation: 0.9689, brightness: 0.8824))
            .foregroundColor(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white, lineWidth: 7)
            )
            .shadow(radius: 5)
        }
    }
}

struct PizzaCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        PizzaOrderCollectionView()
    }
}

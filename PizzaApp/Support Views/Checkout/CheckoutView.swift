//
//  CheckoutView.swift
//  PizzaApp
//
//  Created by Léon Becker on 17.08.20.
//

import SwiftUI

struct CheckoutView: View {
    @State var name = ""
    @FetchRequest(entity: ShoppingCartItem.entity(), sortDescriptors: []) var shoppingCart: FetchedResults<ShoppingCartItem>
    
    var body: some View {
        VStack {
            Text("Kasse")
                .bold()
                .font(.title)
                .padding(.top, 20)
            
            VStack(alignment: .leading) {
                Text("Name:")
                    .bold()
                    .font(.title3)
                
                TextField("Name", text: $name)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                    .keyboardType(.namePhonePad)
                
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Addresse:")
                    .bold()
                    .font(.title3)
                    .padding(.bottom, 5)
                
                TextField("Straße", text: $name)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                
                HStack {
                    TextField("Ort", text: $name)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 2)
                        )

                    
                    TextField("PLZ", text: $name)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            
            Button(action: {}) {
                Text("Kostenpflichtig Bestellen")
            }
        }
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView()
    }
}

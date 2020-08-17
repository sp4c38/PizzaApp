//
//  CheckoutView.swift
//  PizzaApp
//
//  Created by Léon Becker on 17.08.20.
//

import SwiftUI

struct CheckoutView: View {
    @State var name = ""
    @State var selectedPaymentMethod = 1
    @FetchRequest(entity: ShoppingCartItem.entity(), sortDescriptors: []) var shoppingCart: FetchedResults<ShoppingCartItem>
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Kasse")
                .bold()
                .font(.title)
                .padding(.top, 20)
            
            VStack(alignment: .leading) {
                Text("Name:")
                    .bold()
                    .font(.title3)
                
                TextField("Name", text: $name)
                    .frame(maxWidth: .infinity, maxHeight: 16)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 2)
                    )
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            
            VStack(alignment: .leading, spacing: 10) {
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
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Bezahloption:")
                    .bold()
                    .font(.title3)
                Picker(selection: $selectedPaymentMethod, label: Text("Payment Method")) {
                    Text("Vor Ort in Bar").tag(1)
                    Text("Mit Karte").tag(2)
                }.pickerStyle(SegmentedPickerStyle())
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            
            Button(action: {
                let orderSuccessful = secureSendPizzaOrder("https://www.space8.me:7392/pizzaapp/")//, shoppingCartItems: shoppingCart)
                
                if orderSuccessful {
                    print("Order successful.")
                } else if !orderSuccessful {
                    print("Error with sending the order request.")
                }
            }) {
                Text("Kostenpflichtig Bestellen")
                    .foregroundColor(.white)
                    .bold()
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(BuyButtonStyle())
            .padding(30)
            
            
            Spacer()
        }
        .navigationBarTitle("Kasse", displayMode: .inline)
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView()
    }
}

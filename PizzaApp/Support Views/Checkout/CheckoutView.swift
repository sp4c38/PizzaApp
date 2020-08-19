//
//  CheckoutView.swift
//  PizzaApp
//
//  Created by Léon Becker on 17.08.20.
//

import SwiftUI

class OrderDetails: ObservableObject {
    @Published var name: String = "" // Name of the customer
    @Published var street: String = "" // Name of the street the customer lives on
    @Published var city: String = "" // City or village the
    @Published var postalCode: String = ""
    @Published var selectedPaymentMethod: Int8 = 1
}

struct CheckoutView: View {
    @ObservedObject var orderDetails = OrderDetails()
    @FetchRequest(entity: ShoppingCartItem.entity(), sortDescriptors: []) var shoppingCart: FetchedResults<ShoppingCartItem>
    @State var showFieldsRequiredReminder: Bool = false
    
    var shoppingCartArray: [ShoppingCartItem] {
        // Convert the FetchedResult<ShoppingCartItem> which contains an array to type Array<ShoppingCartItem>
        var out = [ShoppingCartItem]()
        for i in shoppingCart {
            out.append(i)
        }
        return out
    }
    
    var body: some View {
        VStack(spacing: 30) {
            if showFieldsRequiredReminder {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.octagon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                    
                    Text("Bitte füllen Sie alle Felder aus")
                        .bold()
                        .font(.title3)
                }
                .foregroundColor(Color.red)
            }
            
            VStack(alignment: .leading) {
                Text("Name:")
                    .bold()
                    .font(.title3)
                
                TextField("Name", text: $orderDetails.name)
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
                
                TextField("Straße", text: $orderDetails.street)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                
                HStack {
                    TextField("Ort", text: $orderDetails.city)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 2)
                        )

                    
                    TextField("PLZ", text: $orderDetails.postalCode)
                        .keyboardType(.numberPad)
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
                Picker(selection: $orderDetails.selectedPaymentMethod, label: Text("Bezahloption")) {
                    Text("Vor Ort in Bar").tag(1)
                    Text("Mit Karte").tag(2)
                }.pickerStyle(SegmentedPickerStyle())
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            
            Button(action: {
                if (orderDetails.name == "") || (orderDetails.street == "") || (orderDetails.city == "")  || (orderDetails.postalCode == "")  {
                    showFieldsRequiredReminder = true
                } else  {
                    let wasSuccessful = sendPizzaOrder("https://www.space8.me:7392/pizzaapp/", shoppingCartItems: shoppingCartArray, orderDetails: orderDetails)

                    if !wasSuccessful {
                        print("Error with sending the order request.")
                    }
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
        .padding(.top, 20)
        .animation(.easeInOut)
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView()
    }
}

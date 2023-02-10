//
//  CheckoutView.swift
//  PizzaApp
//
//  Created by Léon Becker on 17.08.20.
//

import CoreData
import SwiftUI
        
struct PaymentMethod: Identifiable {
    var id: Int8
    var name: String
}

class OrderDetails: ObservableObject {
    @Published var firstname: String = "" // First name of the customer
    @Published var lastname: String = "" // Last name of the customer
    @Published var street: String = "" // Name of the street the customer lives on
    @Published var city: String = "" // City or village the customer lives in
    @Published var postalCode: String = "" // Postalcode of the city or village. This is treated as a String because it otherwise can't be used on TextField's
    
    let paymentMethods: [PaymentMethod] = [PaymentMethod(id: 1, name: "Vor Ort in Bar"), PaymentMethod(id: 2, name: "Mit Karte")]
    
    @Published var selectedPaymentMethod: Int8 = 1
}

func deleteAllShoppingCartItems(allItems: [ShoppingCartItem], viewContext: NSManagedObjectContext) {
    for item in allItems {
        viewContext.delete(item)
    }
    do {
        try viewContext.save()
    } catch {
        fatalError("Couldn't save the view context after deleting all items from it after successful checkout. \(error)")
    }
}

struct CheckoutView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var orderProperty: OrderProperty
    @FetchRequest(entity: ShoppingCartItem.entity(), sortDescriptors: []) var shoppingCart: FetchedResults<ShoppingCartItem>
    
    @State var showErrorMessage: String = ""
    @ObservedObject var orderDetails = OrderDetails()
    
    var shoppingCartArray: [ShoppingCartItem] {
        // Convert the FetchedResult<ShoppingCartItem> which contains an array to type Array<ShoppingCartItem>
        var out = [ShoppingCartItem]()
        for i in shoppingCart {
            out.append(i)
        }
        return out
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ZStack {
                VStack {
                    VStack(spacing: 30) {
                        if showErrorMessage != "" {
                            VStack(spacing: 20) {
                                Image(systemName: "exclamationmark.octagon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                
                                Text(showErrorMessage)
                                    .bold()
                                    .font(.title3)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .foregroundColor(Color.red)
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Name:")
                                .bold()
                                .font(.title3)
                            
                            HStack {
                                TextField("Vorname", text: $orderDetails.firstname)
                                    .frame(maxWidth: .infinity, maxHeight: 16)
                                    .padding()
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                                    .disableAutocorrection(true)
                                TextField("Nachname", text: $orderDetails.lastname)
                                    .frame(maxWidth: .infinity, maxHeight: 16)
                                    .padding()
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                                    .disableAutocorrection(true)
                            }
                        }
                        .padding(.leading, 16)
                        .padding(.trailing, 16)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Addresse:")
                                .bold()
                                .font(.title3)
                                .padding(.bottom, 5)
                                .disableAutocorrection(true)
                            
                            TextField("Straße", text: $orderDetails.street)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 2)
                                )
                                .disableAutocorrection(true)
                            
                            HStack {
                                TextField("Ort", text: $orderDetails.city)
                                    .padding()
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                                    .disableAutocorrection(true)
                                
                                TextField("PLZ", text: $orderDetails.postalCode)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                                    .disableAutocorrection(true)
                            }
                        }
                        .padding(.leading, 16)
                        .padding(.trailing, 16)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Bezahloption:")
                                .bold()
                                .font(.title3)
                            Picker(selection: $orderDetails.selectedPaymentMethod, label: Text("Bezahloption")) {
                                ForEach(orderDetails.paymentMethods, id: \.id) { paymentMethod in
                                    Text(paymentMethod.name)
                                }
                            }.pickerStyle(SegmentedPickerStyle())
                        }
                        .padding(.leading, 16)
                        .padding(.trailing, 16)
                        
                        NavigationLink(destination: HomeView().environmentObject(orderProperty), isActive: $orderProperty.showOrderSuccessful) {
                            Button(action: {
                                // All requirements to the order details are also again checked on server side
                                let fieldsEnteredCorrectly = checkoutValidateFields(orderDetails)
                                
                                if fieldsEnteredCorrectly.0 {
                                    let wasSuccessful = sendPizzaOrder("https://www.space8.me:7392/pizzaapp/save_order",  shoppingCartItems: shoppingCartArray, orderDetails: orderDetails)
                                        
                                    if wasSuccessful {
                                        orderProperty.showOrderSuccessful = true
                                        let newSavedOrder = Order(context: managedObjectContext)
                                        var allOrderedPizzas = [StoredOrderedPizza]()
                                        
                                        for pizza in shoppingCartArray {
                                            allOrderedPizzas.append(StoredOrderedPizza(pizzaId: pizza.pizzaId, pizzaSizeIndex: pizza.sizeIndex))
                                        }
                                        
                                        let orders = StoredOrderData(allStoredPizzas: allOrderedPizzas)
                                        let encodedOrders: Data
                                        
                                        let jsonEncoder = JSONEncoder()
                                        do {
                                            encodedOrders = try jsonEncoder.encode(orders)
                                        } catch {
                                            fatalError("Couldn't convert ordered pizzas to json to store in Core Data.")
                                        }
                                        
                                        newSavedOrder.pizzasOrdered = encodedOrders
                                        newSavedOrder.firstname = orderDetails.firstname
                                        newSavedOrder.lastname = orderDetails.lastname
                                        newSavedOrder.street = orderDetails.street
                                        newSavedOrder.postalCode = Int32(orderDetails.postalCode)!
                                        newSavedOrder.city = orderDetails.city
                                        newSavedOrder.paymentMethod = Int16(orderDetails.selectedPaymentMethod)
                                        
                                        // When deleting all shopping cart items in the next step the viewContext also get's stored. Don't need to store the data to the device twice here. Also when creating a new item here for the devices storage.
                                        
                                        deleteAllShoppingCartItems(allItems: shoppingCartArray, viewContext: managedObjectContext)
                                        print("Saved new order and deleted all shopping cart items out of the devices storage.")
                                    } else {
                                        showErrorMessage = "Ihre Bestellung kann nicht verarbeitet werden. Bitte versuchen Sie es später noch einmal."
                                    }
                                } else  {
                                    showErrorMessage = fieldsEnteredCorrectly.1
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
                            .padding(.top, 10)
                            .padding(.leading, 30)
                            .padding(.trailing, 30)
                        }
                    }
                    .navigationBarTitle("Kasse", displayMode: .inline)
                    .padding(.top, 35)
                    .animation(.easeInOut)
                }
            }
        }
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView()
    }
}

//
//  CheckoutView.swift
//  PizzaTech
//
//  Created by Léon Becker on 12.06.21.
//

import SwiftUI

extension View {
    /// Hides the keyboard from the screen
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


struct YourDataFieldViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .padding(.leading, 10)
            .background(
                Color.white
                    .cornerRadius(10)
                    .shadow(radius: 10)
            )
    }
}

struct OrderButtonButtonStyle: ButtonStyle {
    var buttonTaps: Int
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding([.top, .bottom], 20)
            .background(buttonTaps == 0 ? Color.red : buttonTaps == 1 ? Color.green : Color.gray)
            .cornerRadius(20)
            .padding([.leading, .trailing], 16)
            .shadow(radius: 10)
    }
}

struct CheckoutView: View {
    @EnvironmentObject var catalogService: CatalogService
    @State var orderSending = false
    @State var orderSuccessful = false
    @FetchRequest(entity: OrderedItem.entity(), sortDescriptors: []) var orderedItems: FetchedResults<OrderedItem>
    @State var orderButtonTaps: Int = 0
    
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var street: String = ""
    @State var city: String = ""
    @State var postalCode: String = ""
    
    let numberFormatter = { () -> NumberFormatter in
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.decimalSeparator = ","
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }()
    
    var body: some View {
        GeometryReader {_ in
            VStack(spacing: 30) {
                NavigationLink("", destination: HomeView(), isActive: $orderSuccessful)
                    .frame(width: 0, height: 0)
                VStack(spacing: 30) {
                    TextField("Vorname", text: $firstName)
                        .modifier(YourDataFieldViewModifier())
                    TextField("Nachname", text: $lastName)
                        .modifier(YourDataFieldViewModifier())
                    TextField("Straße + Hausnummer", text: $street)
                        .modifier(YourDataFieldViewModifier())
                    HStack {
                        TextField("Stadt", text: $city)
                            .modifier(YourDataFieldViewModifier())
                        TextField("PLZ", text: $postalCode)
                            .modifier(YourDataFieldViewModifier())
                            .keyboardType(.numberPad)
                    }
                }
                .disabled(orderSending ? true : false)
                .opacity(orderSending ? 0.4 : 1)
                
                Spacer(minLength: 0)
                
                VStack(alignment: .center) {
                    HStack {
                        Text("Gesammt")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    Text("\(numberFormatter.string(from: NSNumber(value: calculateAllPrice()))!) €")
                        .bold()
                        .font(.title)
                }
                .ignoresSafeArea(.keyboard)
                .padding(.top, 10)
                .padding(.leading, 12)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity)
                .background(
                    Color.white
                        .cornerRadius(10)
                        .shadow(radius: 10)
                )
                .disabled(orderSending ? true : false)
                .opacity(orderSending ? 0.4 : 1)
                
                Spacer(minLength: 0)
                
                Button(action: {
                    if orderButtonTaps == 0 || orderButtonTaps == 1 {
                        withAnimation(.easeInOut) {
                            orderButtonTaps += 1
                        }
                    }
                    if orderButtonTaps == 2 {
                        withAnimation {
                            orderSending = true
                            orderItems()
                        }
                    }
                }) {
                    HStack(spacing: 10) {
                        if orderButtonTaps == 0 {
                            Image(systemName: "creditcard")
                                .font(.title2)
                            Text("Bestellen")
                        } else if orderButtonTaps == 1 {
                            Image(systemName: "checkmark")
                                .font(.title2)
                            Text("Bestätigen")
                        } else if orderButtonTaps == 2 {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                            Text("Bestellung wird verschickt")
                                .bold()
                                .foregroundColor(.white)
                        }
                    }
                }
                .ignoresSafeArea(.keyboard)
                .buttonStyle(OrderButtonButtonStyle(buttonTaps: orderButtonTaps))
            }
            .padding(.top, 30)
            .padding(.bottom, 16)
            .navigationTitle("Deine Daten")
            .padding([.leading, .trailing])
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
            .ignoresSafeArea(.keyboard)
        }
        .ignoresSafeArea(.keyboard)
    }
    
    func calculateAllPrice() -> Double {
        var allPrice: Double = 0
        for order in orderedItems {
            allPrice += order.price
        }
        return allPrice
    }
    
    func orderItems() {
        var orderRequestItems = [OrderRequestItem]()
        for item in orderedItems {
            let newRequestItem = OrderRequestItem(item_id: Int(item.item_id), price: item.price, quantity: Int(item.quantity))
            orderRequestItems.append(newRequestItem)
        }
        let details = OrderRequestDetails(first_name: firstName, last_name: lastName, street: street, city: city, postal_code: postalCode)
        
        let newOrderRequest = OrderRequest(items: orderRequestItems, details: details)
        
        let jsonEncoder = JSONEncoder()
        let encodedNewOrderRequest = try! jsonEncoder.encode(newOrderRequest)
        
        var request = URLRequest(url: URL(string: "https://www.space8.me:7392/order/make/")!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Content-Type": "application/json"]
        request.httpBody = encodedNewOrderRequest

        let startTime = Date()
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if error == nil {
                print("Error: \(String(describing: error)).")
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("Status \(httpResponse.statusCode)")
                print("Order should be successful.")
            }
            let endTime = Date()
            if endTime.timeIntervalSince(startTime) < TimeInterval(3) {
                let diff = 3 - endTime.timeIntervalSince(startTime)
                DispatchQueue.main.asyncAfter(deadline: .now() + diff) {
                    orderSuccessful = true
                    catalogService.showThanksForOrder = true
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                        catalogService.showThanksForOrder = false
                    }
                }
            }
        }).resume()
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CheckoutView()
        }
    }
}

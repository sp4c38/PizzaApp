//
//  RealOrderView.swift
//  PizzaTech
//
//  Created by Léon Becker on 13.06.21.
//

import SwiftUI

struct RealOrderD {
    var firstName = "Paul"
    var lastName = "Becker"
    var pizzasOrdered: Data? = nil
    var street = "Irgendeinerstraße 19"
    var postalCode = "01477"
    var city = "Dresden"
    
    init() {
        let encoder = JSONEncoder()
        var encodedPizzasOrdered: Data? = nil
        do {
            encodedPizzasOrdered = try encoder.encode([OrderRequestItem(item_id: 1, price: 19.99, quantity: 2), OrderRequestItem(item_id: 5, price: 12.99, quantity: 1)])
        } catch {
            fatalError("Couldn't encode pizzas ordered.")
        }
        self.pizzasOrdered = encodedPizzasOrdered
    }
}

struct RealOrderPreviewView: View {
    var realOrder: RealOrder
    @State var decodedPizzasOrdered: [OrderRequestItem]? = nil
    @State var isActive = false
    
    let numberFormatter = { () -> NumberFormatter in
        var numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.decimalSeparator = ","
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }()
    
    var body: some View {
        VStack {
            if decodedPizzasOrdered != nil {
                NavigationLink(
                    destination: OrderInfoView(realOrder: realOrder, decodedPizzasOrdered: decodedPizzasOrdered!),
                    isActive: $isActive) {}.frame(width: 0, height: 0)
                Button(action: { isActive = true }) {
                    HStack {
                        HStack(spacing: 30) {
                            Image("orderTruck")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70)
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(getCountString(count: decodedPizzasOrdered!.count))
                                    .font(.caption)
                                Spacer()
                                Text("\(numberFormatter.string(from: NSNumber(value: calcAllPrice()))!) €")
                                    .bold()
                                    .padding(.bottom, 4)
                            }
                        }
                        .padding([.leading, .trailing], 20)
                        .padding([.top, .bottom], 7)
                        .background(Color.white.cornerRadius(10).shadow(radius: 10))
                        .padding([.leading, .trailing], 10)
                    }
                    .padding([.top, .bottom], 9)
                    .frame(maxWidth: .infinity)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(Color.red.cornerRadius(10).shadow(radius: 10))
                    .padding([.leading, .trailing])
                }
            }
        }
        .onAppear {
            decodePizzasOrdered()
        }
    }
       
    func getCountString(count: Int) -> String {
        if count == 1 {
            return "Eine Ware bestellt."
        } else {
            return "\(count) Waren bestellt."
        }
    }
    
    func calcAllPrice() -> Double {
        var allPrice: Double = 0
        for p in decodedPizzasOrdered! {
            allPrice += p.price
        }
        return allPrice
    }
    
    func decodePizzasOrdered() {
        let decoder = JSONDecoder()
        var decodedOrderRequestItems: [OrderRequestItem]
        do {
            decodedOrderRequestItems = try decoder.decode([OrderRequestItem].self, from: realOrder.pizzasOrdered!)
        } catch {
            fatalError("Couldn't decode order request items.")
        }
        self.decodedPizzasOrdered = decodedOrderRequestItems
    }
}

struct RealOrderView: View {
    @FetchRequest(entity: RealOrder.entity(), sortDescriptors: []) var realOrders: FetchedResults<RealOrder>
    
    var body: some View {
        ScrollView {
            VStack(spacing: 35) {
                ForEach(realOrders) { realOrder in
                    RealOrderPreviewView(realOrder: realOrder)
                }
                Spacer()
            }
            .navigationTitle("Bestellungen")
            .padding(.top, 20)
        }
    }
}

//struct RealOrderView_Previews: PreviewProvider {
//    static var previews: some View {
//        RealOrderPreviewView(realOrder: RealOrderD())
//    }
//}

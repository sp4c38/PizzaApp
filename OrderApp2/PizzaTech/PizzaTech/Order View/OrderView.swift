//
//  OrderView.swift
//  PizzaTech
//
//  Created by Léon Becker on 11.06.21.
//

import SwiftUI

struct SingleOrderedItemView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    let orderedItem: OrderedItem
    let item: CatalogGeneralItem?
    
    let numberFormatter = { () -> NumberFormatter in
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.decimalSeparator = ","
        return numberFormatter
    }()
    
    var body: some View {
        if item != nil {
            HStack(alignment: .top) {
                ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom)) {
                    Image(item!.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 210)
                    
                    Button(action: { deleteItem() } ) {
                        Image(systemName: "trash")
                            .padding(10)
                            .foregroundColor(.red)
                            .background(Color.white.cornerRadius(10).shadow(radius: 10))
                            .padding([.leading, .bottom], 8)
                    }
                }
                
                Spacer(minLength: 6)
                
                VStack(alignment: .trailing, spacing: 0) {
                    Text(item!.name)
                        .bold()
                        .font(.callout)
                        .padding(.bottom, 4)
                    
                    Text("\(orderedItem.quantity)x")
                    Spacer(minLength: 0)
                    Text("\(numberFormatter.string(for: orderedItem.price)!) €")
                        .bold()
                        .font(.body)
                        .padding(.bottom, 10)
                }
                .padding(.top, 15)
                .padding(.trailing, 15)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .cornerRadius(10)
            .padding([.leading, .trailing])
            .fixedSize(horizontal: false, vertical: true)
            .shadow(radius: 10)
        } else {
            VStack {}
        }
    }
        
    func deleteItem() {
            managedObjectContext.delete(orderedItem)
        do {
            try withAnimation {
                try managedObjectContext.save()
            }
            print("Deleted and saved.")
        } catch {
            print("Error while saving deleted ordered item: \(error).")
        }
    }
}


struct OrderView: View {
    @EnvironmentObject var catalogService: CatalogService
    @State var isActive = false
    @FetchRequest(entity: OrderedItem.entity(), sortDescriptors: []) var orderedItems: FetchedResults<OrderedItem>
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 40) {
                    ForEach(orderedItems) { orderedItem in
                        SingleOrderedItemView(orderedItem: orderedItem, item: getCatalogItem(order: orderedItem))
                    }
                }
                .padding(.top, 20)
            }
            Spacer()
            NavigationLink(destination: CheckoutView(), isActive: $isActive) {
                Button(action: { isActive = true }) {
                    HStack(spacing: 10) {
                        Image(systemName: "creditcard")
                            .font(.title2)
                        Text("Weiter zur Kasse")
                            .bold()
                    }
                }
                .buttonStyle(ToCheckoutButtonStyle())
            }
        }
        .navigationTitle("Warenkorb")
        .padding(.bottom)
    }
    
    func getCatalogItem(order: OrderedItem) -> CatalogGeneralItem? {
        guard let catalog = catalogService.catalog else {
            return nil
        }
        let categories = catalog.categories
        let item_id = order.item_id
        var foundItem: CatalogGeneralItem? = nil
        for item in categories.pizza.items { if item.id == item_id { foundItem = item } }
        for item in categories.burger.items { if item.id == item_id { foundItem = item } }
        for item in categories.iceDessert.items { if item.id == item_id { foundItem = item } }
        for item in categories.salad.items { if item.id == item_id { foundItem = item } }
        for item in categories.drink.items { if item.id == item_id { foundItem = item } }
        for item in categories.pasta.items { if item.id == item_id { foundItem = item } }
        if foundItem != nil {
            print("Found item: \(String(describing: foundItem)).")
        }
        return foundItem
    }
}

struct OrderRequestItem: Codable {
    var item_id: Int
    var price: Double
    var quantity: Int
}

struct OrderRequestDetails: Encodable {
    var first_name: String
    var last_name: String
    var street: String
    var city: String
    var postal_code: String
}

struct OrderRequest: Encodable {
    var items: [OrderRequestItem]
    var details: OrderRequestDetails
}

struct ToCheckoutButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding([.top, .bottom], 20)
            .background(Color.red)
            .cornerRadius(20)
            .padding([.leading, .trailing], 16)
            .shadow(radius: 10)
    }
}

struct OrderView_Previews: PreviewProvider {
    static var previews: some View {
//        SingleOrderedItemView(orderedItem: OrderedItemD(), item: PizzaItem(id: 1, name: "Marherita", imageName: "margherita", prices: [1,2,3], ingredientDescription: "oeitjiuhbketjhgbjkheruigbjieurjhbiuheijh", speciality: FoodCharacteristics(vegetarian: true, vegan: false, spicy: false)))
        Button(action: {}) {
            HStack(spacing: 10) {
                Image(systemName: "creditcard")
                    .font(.title2)
                Text("Weiter zur Kasse")
                    .bold()
            }
        }
        .buttonStyle(ToCheckoutButtonStyle())
    }
}

//
//  ItemInfo.swift
//  PizzaTech
//
//  Created by Léon Becker on 06.03.21.
//

import SwiftUI

struct ScaledFont: ViewModifier {
    var size: CGFloat

    func body(content: Content) -> some View {
       let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        return content.font(.custom("", size: scaledSize))
    }
}

@available(iOS 13, macCatalyst 13, tvOS 13, watchOS 6, *)
extension View {
    func scaledFont(size: CGFloat) -> some View {
        return self.modifier(ScaledFont(size: size))
    }
}

extension View {
    @ViewBuilder func ifTrue<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        } else {
            self
        }
    }
}

struct AddToBasketButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .cornerRadius(10)
            .padding([.leading, .trailing], 16)
            .font(.body)
            .shadow(radius: 10)
    }
}

struct IngredientDescription: View {
    var description: String
    
    var body: some View {
        HStack {
            Text(description)
                .font(.callout)
                .foregroundColor(.gray)
        }
        .padding([.top, .bottom], 12)
        .padding([.leading, .trailing], 15)
//        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct ItemSizePickerButtonStyle: ButtonStyle {
    var isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 30, height: 30)
            .font(.title)
            .padding(15)
            .background(
                Circle().foregroundColor(.red)
                    .shadow(color: .black, radius: isSelected ? 1 : 3, x: 0.0, y: 1.3)
                    .background(
                    Circle()
                        .stroke(Color.blue, lineWidth: isSelected ? 12: 0)
                        .shadow(radius: isSelected ? 3 : 0)
                )
            )
    }
}

struct ItemSizePicker: View {
    @Binding var selectedPriceIndex: Int
    
    let prices: [Float]
    
    let numberFormatter = { () -> NumberFormatter in
        let numberFormatter = NumberFormatter()
        numberFormatter.decimalSeparator = ","
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }()

    var body: some View {
        HStack(spacing: 40) {
            if prices.count == 3 {
                VStack(spacing: 15) {
                    Button(action: { selectedPriceIndex = 0 }) {
                        Text("S").foregroundColor(.white)
                    }.buttonStyle(ItemSizePickerButtonStyle(isSelected: selectedPriceIndex == 0))
                    Text("\(numberFormatter.string(for: prices[0])!) €")
                        .padding(.leading, 8)
                }
                VStack(spacing: 15) {
                    Button(action: { selectedPriceIndex = 1 }) {
                        Text("M").foregroundColor(.white)
                    }.buttonStyle(ItemSizePickerButtonStyle(isSelected: selectedPriceIndex == 1))
                    Text("\(numberFormatter.string(for: prices[1])!) €")
                        .padding(.leading, 8)
                }
                VStack(spacing: 15) {
                    Button(action: { selectedPriceIndex = 2 }) {
                        Text("L").foregroundColor(.white)
                    }.buttonStyle(ItemSizePickerButtonStyle(isSelected: selectedPriceIndex == 2))
                    Text("\(numberFormatter.string(for: prices[2])!) €")
                        .padding(.leading, 8)
                }
            } else if prices.count == 1 {
                Text("\(numberFormatter.string(for: prices[0])!) €")
                    .bold()
                    .font(.title)
            }
        }
        .ifTrue(prices.count == 3) { content in
            content
            .animation(.easeInOut(duration: 0.2))
        }
        .ifTrue(prices.count == 1) { content in
            content
        }
        .frame(maxWidth: .infinity)
        .padding([.top, .bottom], 20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding([.leading, .trailing], 16)
    }
}

struct ItemInfo<T: CatalogGeneralItem>: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var selectedPriceIndex: Int = 0
    @State var quantity = 1
    
    var item: T
    let numberFormatter = { () -> NumberFormatter in
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.decimalSeparator = ","
        return numberFormatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            Image(item.imageName)
                .resizable()
                .cornerRadius(10)
                .scaledToFit()
                .padding([.leading, .trailing], 16)
                .padding(.top, 13)
                .padding(.bottom, 13)
                .shadow(radius: 10)
            
            IngredientDescription(description: item.ingredientDescription)
                .padding(.bottom, 40)
                .padding(.top, 20)
            
            ItemSizePicker(selectedPriceIndex: $selectedPriceIndex, prices: item.prices)
            
            Spacer()
            VStack(spacing: 0) {
                Text("Menge")
                    .bold()
                    .font(.footnote)
                    .padding(.bottom, 2)
                
                HStack {
                    Image(systemName: "plus")
                        .onTapGesture { withAnimation { quantity += 1 } }
                        .font(.title2)
                        .frame(width: 35, height: 35)
                        .contentShape(Rectangle())
                    Text(String(quantity))
                        .animation(nil)
                        .font(.title2)
                    Image(systemName: "minus")
                        .colorMultiply(quantity == 1 ? Color(red: 0.84, green: 0.84, blue: 0.84) : .white)
                        .onTapGesture { minusQuantity() }
                        .font(.title2)
                        .frame(width: 35, height: 35)
                        .contentShape(Rectangle())
                }
            }
            .foregroundColor(.white)
            .padding([.leading, .trailing], 8)
            .padding([.top, .bottom], 6)
            .background(
                RoundedRectangle(cornerRadius: 40)
                    .foregroundColor(.red)
            )
            .padding(.bottom, 40)
            .shadow(radius: 10)
            
            Button(action: {
                let newOrderedItem = OrderedItem(context: managedObjectContext)
                newOrderedItem.item_id = Int64(item.id)
                newOrderedItem.price = Double(item.prices[selectedPriceIndex])
                newOrderedItem.quantity = Int64(quantity)
                
                do {
                    try managedObjectContext.save()
                    print("Saved")
                } catch {
                    fatalError("Managed object context")
                }
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "cart.badge.plus")
                    Text("Hinzufügen")
                }
            }
            .buttonStyle(AddToBasketButtonStyle())
        }
        .navigationTitle(item.name)
    }
    
    func minusQuantity() {
        if quantity >= 2 {
            withAnimation {
                quantity -= 1
            }
        }
    }
}

struct ItemInfo_Previews: PreviewProvider {
    static var previews: some View {
        let decoder = JSONDecoder()
        let pizzaItemData = """
            {
            "id": 1,
            "image_name": "margherita",
            "ingredient_description": "mit Pizzasoße und echtem Gouda",
            "name": "Margherita",
            "prices": [
              6.99,
              9.99,
              11.99
            ],
            "speciality": {
              "spicy": false,
              "vegan": false,
              "vegetarian": true
            }
          }
        """.data(using: .utf8)!
        let pizzaItem = try! decoder.decode(PizzaItem.self, from: pizzaItemData)
        let persistenceManager = PersistenceManager()

        return NavigationView {
            ItemInfo(item: pizzaItem).environment(\.managedObjectContext, persistenceManager.persistentContainer.viewContext)
        }
    }
}

//struct TestView: View {
//    @State var selectedIndex = 0
//    var body: some View {
//        ItemSizePicker(selectedPriceIndex: $selectedIndex, prices: [5.21, 12.34, 19.31])
//    }
//}
//
//struct ItemInfo_Previews: PreviewProvider {
//    static var previews: some View {
//        TestView()
//    }
//}

//struct ItemInfo_Previews: PreviewProvider {
//    static var previews: some View {
//        return NavigationView {
//            Button(action: {}) {
//                HStack(spacing: 10) {
//                    Image(systemName: "cart.badge.plus")
//                    Text("Hinzufügen")
//                }
//            }
//            .buttonStyle(AddToBasketButtonStyle())
//        }
//    }
//}

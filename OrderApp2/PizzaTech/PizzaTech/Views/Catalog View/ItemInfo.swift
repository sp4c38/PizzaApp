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
        .frame(maxWidth: .infinity)
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
                    .shadow(color: .gray, radius: 10)
                    .background(
                    Circle()
                        .stroke(Color.blue, lineWidth: isSelected ? 12 : 0)
                        .shadow(radius: isSelected ? 10 : 0)
                )
            )
    }
}

struct SizeButtonTextModifier: ViewModifier {
    var isSelected: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(isSelected ? 5 : 0)
            .padding([.leading, .trailing], isSelected ? 3 : 0)
            .background(Color.white.cornerRadius(isSelected ? 7 : 0).shadow(radius: isSelected ? 10 : 0))
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
                    Button(action: { withAnimation(.easeInOut(duration: 0.13)) { selectedPriceIndex = 0 } }) {
                        Text("S").foregroundColor(.white)
                    }.buttonStyle(ItemSizePickerButtonStyle(isSelected: selectedPriceIndex == 0))
                    Text("\(numberFormatter.string(for: prices[0])!) €")
                        .padding(.leading, selectedPriceIndex == 0 ? 0 : 8)
                        .modifier(SizeButtonTextModifier(isSelected : selectedPriceIndex == 0))
                }
                VStack(spacing: 15) {
                    Button(action: { withAnimation(.easeInOut(duration: 0.13)) { selectedPriceIndex = 1 } }) {
                        Text("M").foregroundColor(.white)
                    }.buttonStyle(ItemSizePickerButtonStyle(isSelected: selectedPriceIndex == 1))
                    Text("\(numberFormatter.string(for: prices[1])!) €")
                        .padding(.leading, selectedPriceIndex == 1 ? 0 : 8)
                        .modifier(SizeButtonTextModifier(isSelected : selectedPriceIndex == 1))
                }
                VStack(spacing: 15) {
                    Button(action: { withAnimation(.easeInOut(duration: 0.13)) { selectedPriceIndex = 2 } }) {
                        Text("L").foregroundColor(.white)
                    }.buttonStyle(ItemSizePickerButtonStyle(isSelected: selectedPriceIndex == 2))
                    Text("\(numberFormatter.string(for: prices[2])!) €")
                        .padding(.leading, selectedPriceIndex == 2 ? 0 : 8)
                        .modifier(SizeButtonTextModifier(isSelected : selectedPriceIndex == 2))
                }
            } else if prices.count == 1 {
                Text("\(numberFormatter.string(for: prices[0])!) €")
                    .bold()
                    .font(.title)
            }
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
    @State var selectedPriceIndex: Int = 1
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
                .padding(.bottom, 5)
                .shadow(radius: 10)
            
            Spacer()
            
            IngredientDescription(description: item.ingredientDescription)
                .padding([.leading, .trailing])
            
            Spacer()
            
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
                        .frame(width: 45, height: 45)
                        .contentShape(Rectangle())
                    Text(String(quantity))
                        .font(.title2)
                    Image(systemName: "minus")
                        .colorMultiply(quantity == 1 ? Color(red: 0.84, green: 0.84, blue: 0.84) : .white)
                        .onTapGesture { minusQuantity() }
                        .font(.title2)
                        .frame(width: 45, height: 45)
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
            .shadow(radius: 10)
            
            Spacer()
            
            Button(action: {
                let newOrderedItem = OrderedItem(context: managedObjectContext)
                newOrderedItem.item_id = Int64(item.id)
                if item.prices.count == 1 {
                    newOrderedItem.price = Double(item.prices[0])
                } else {
                    newOrderedItem.price = Double(item.prices[selectedPriceIndex])
                }
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
            .padding(.bottom)
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

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

struct ItemInfo<T: CatalogGeneralItem>: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var selectedPrice: Double = 0
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
            Text(item.name)
                .bold()
                .font(.title)
                .padding(.bottom, 15)
            
            Image(item.imageName)
                .resizable()
                .scaledToFit()
                .padding(.bottom, 13)
            
            Text(item.ingredientDescription)
                .font(.callout)
                .opacity(0.8)
                .padding(.bottom, 20)
            
            HStack {
                Image(systemName: "plus")
                    .onTapGesture { withAnimation { quantity += 1 } }
                Text(String(quantity))
                    .animation(nil)
                    .font(.title3)
                Image(systemName: "minus")
                    .colorMultiply(quantity == 1 ? Color(red: 0.84, green: 0.84, blue: 0.84) : .white)
                    .onTapGesture { minusQuantity() }
            }
            .foregroundColor(.white)
            .padding([.leading, .trailing], 8)
            .padding([.top, .bottom], 3)
            .background(
                RoundedRectangle(cornerRadius: 40)
                    .foregroundColor(.red)
            )
                
            Spacer()
            
            Button(action: {
                var newOrderedItem = OrderedItem(context: managedObjectContext)
                newOrderedItem.item_id = Int64(item.id)
                newOrderedItem.price = selectedPrice
                newOrderedItem.quantity = Int64(quantity)
                
                do {
                    try managedObjectContext.save()
                    print("Saved")
                } catch {
                    fatalError("Managed object context")
                }
            }) {
                Text("Add to basket.")
            }
        }
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
        
        return ItemInfo(item: pizzaItem).environment(\.managedObjectContext, persistenceManager.persistentContainer.viewContext)
    }
}

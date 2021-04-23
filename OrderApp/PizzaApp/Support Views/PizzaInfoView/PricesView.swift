//
//  PricesView.swift
//  PizzaApp
//
//  Created by Léon Becker on 14.08.20.
//

import SwiftUI

struct SinglePriceView: View {
    var item: ItemDisplayInfo
    let numberFormatter: NumberFormatter
    
    init(_ item: ItemDisplayInfo) {
        self.item = item
        numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "de_DE")
        numberFormatter.numberStyle = .currency
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Text("Preis:")
                    .font(.title2)
                    .bold()
                Spacer()
                Text(
                    numberFormatter.string(
                        from: NSNumber(value: item.singlePrice)
                    ) ?? "NaN")
                    .font(.title3)
                    .bold()
            }
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(Color.white)
        .font(.headline)
        .padding()
        .background(Color(hue: 0.9916, saturation: 0.9689, brightness: 0.8824))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 5)
                .foregroundColor(Color.white)
        )
        .shadow(radius: 6)
        .padding([.leading, .trailing], 16)
        .animation(.easeOut(duration: 0.2))
    }
}

struct SizeSelection {
    var id: Int
    var name: String
}

struct PricesView: View {
    @Binding var selectedSizeIndex: Int
    
    var sizesInfo: [String: [String]]
    var item: ItemDisplayInfo
    
    var sizeSelection = [
        SizeSelection(id: 0, name: catalog.info["sizes"]![0]),
        SizeSelection(id: 1, name: catalog.info["sizes"]![1]),
        SizeSelection(id: 2, name: "\(catalog.info["sizes"]![2])")
    ]

    init(_ item: ItemDisplayInfo, _ sizesInfo: [String: [String]], _ selectedSizeIndex: Binding<Int>) {
        UISegmentedControl.appearance().selectedSegmentTintColor = .white
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        
        self.sizesInfo = sizesInfo
        self.item = item
        self._selectedSizeIndex = selectedSizeIndex
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Größen:")
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 10)
                Spacer()
            }
                
            ForEach(sizesInfo["sizes"]!, id: \.self) { size in
                let index = sizesInfo["sizes"]!.firstIndex(of: size)!
                HStack {
                    Text(size)
                        .foregroundColor(Color.white)
                        .padding(.leading, (index == selectedSizeIndex) ?  5 : 0)
                        .padding(.leading, (!(index == selectedSizeIndex) ? 0 : (!(size.count > 6) ? 0 : 5)))
                        .scaleEffect((index == selectedSizeIndex) ? 1.2 : 1.0)
                    Spacer()
                    Text("\(String(item.prices[index])) €")
                        .foregroundColor(Color.white)
                        .padding(.trailing, (index == selectedSizeIndex) ?  5: 0)
                        .scaleEffect((index == selectedSizeIndex) ? 1.2 : 1.0)
                }
                .padding(.bottom, 4)
                .padding(3)
                .padding(.top, 2)
                .padding(.leading, 3)
                .padding(.trailing, 3)
                .background((index == selectedSizeIndex) ? Color(hue: 1.0000, saturation: 0.5814, brightness: 0.9400) : nil)
                .cornerRadius(4)
            }
            
            Picker(selection: $selectedSizeIndex, label: Text("Größe auswählen: ")) {
                ForEach(sizeSelection, id: \.id) { size in
                    Text(size.name)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(-1)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 2)
            )
            .pickerStyle(SegmentedPickerStyle())
            .scaleEffect(1.25)
            .padding(.leading, 30)
            .padding(.trailing, 30)
            .padding(.top, 15)
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(Color.white)
        .font(.headline)
        .padding()
        .background(Color(hue: 0.9916, saturation: 0.9689, brightness: 0.8824))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 5)
                .foregroundColor(Color.white)
        )
        .shadow(radius: 6)
        .padding(.leading, 16)
        .padding(.trailing, 16)
        .animation(.easeOut(duration: 0.2))
    }
}

struct PricesView_Previews: PreviewProvider {
    static var previews: some View {
        SinglePriceView(
            ItemDisplayInfo(
                id: 0,
                name: "Test Info Name",
                imageName: "Test Image Name",
                ingredientDescription: "Test Ingredient Description",
                dishHints: [],
                singlePrice: 20
            )
        )
    }
}

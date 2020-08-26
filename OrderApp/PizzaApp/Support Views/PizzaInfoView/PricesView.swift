//
//  PricesView.swift
//  PizzaApp
//
//  Created by Léon Becker on 14.08.20.
//

import SwiftUI

struct SizeSelection {
    var id: Int
    var name: String
}

struct PricesView: View {
    var selectedSizeIndex: Binding<Int>
    
    var info: [String: [String]]
    var pizza: Pizza
    
    var sizeSelection = [SizeSelection(id: 0, name: PizzaCatalog.info["sizes"]![0]), SizeSelection(id: 1, name: PizzaCatalog.info["sizes"]![1]), SizeSelection(id: 2, name: "\(PizzaCatalog.info["sizes"]![2]) ")]

    init(info: [String: [String]], pizza: Pizza, selectedSizeIndex: Binding<Int>) {
        UISegmentedControl.appearance().selectedSegmentTintColor = .white
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        
        self.info = info
        self.pizza = pizza
        self.selectedSizeIndex = selectedSizeIndex
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
            
            ForEach(info["sizes"]!, id: \.self) { size in
                let index = info["sizes"]!.firstIndex(of: size)
                HStack {
                    Text(size)
                        .foregroundColor(Color.white)
                        .padding(.leading, (index! == selectedSizeIndex.wrappedValue) ?  5 : 0)
                        .padding(.leading, (!(index! == selectedSizeIndex.wrappedValue) ? 0 : (!(size.count > 6) ? 0 : 5)))
                        .scaleEffect((index! == selectedSizeIndex.wrappedValue) ? 1.2 : 1.0)
                    Spacer()
                    Text("\(String(pizza.prices[index!])) €")
                        .foregroundColor(Color.white)
                        .padding(.trailing, (index! == selectedSizeIndex.wrappedValue) ?  5: 0)
                        .scaleEffect((index! == selectedSizeIndex.wrappedValue) ? 1.2 : 1.0)
                }
                .padding(.bottom, 4)
                .padding(3)
                .padding(.top, 2)
                .padding(.leading, 3)
                .padding(.trailing, 3)
                .background((index! == selectedSizeIndex.wrappedValue) ? Color(hue: 1.0000, saturation: 0.5814, brightness: 0.9400) : nil)
                .cornerRadius(4)
            }
            
            Picker(selection: selectedSizeIndex, label: Text("Größe auswählen: ")) {
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
        PizzaInfoView(info: PizzaCatalog.info, pizza: PizzaCatalog.pizzas[0])
    }
}

//
//  ItemExtraInfoViews.swift
//  PizzaApp
//
//  Created by Léon Becker on 30.08.20.
//

import SwiftUI

struct IsVegetarianView: View {
    var body: some View {
        Text("Vegetarisch")
            .shadow(radius: 5)
            .foregroundColor(Color.white)
            .padding(5)
            .background(Color(hue: 0.2100, saturation: 0.6447, brightness: 0.7725))
            .cornerRadius(5)
    }
}

struct IsVeganView: View {
    var body: some View {
        Text("Vegan")
            .shadow(radius: 5)
            .foregroundColor(Color.white)
            .padding(5)
            .background(Color(hue: 0.3443, saturation: 0.8760, brightness: 0.4745))
            .cornerRadius(5)
    }
}

struct IsSpicyView: View {
    var body: some View {
        Text("🔥 Pikant")
            .shadow(radius: 5)
            .foregroundColor(Color.white)
            .padding(5)
            .background(Color.red)
            .cornerRadius(5)
    }
}

struct PizzaExtraInfoViews_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            IsVegetarianView()
            IsVeganView()
            IsSpicyView()
        }
    }
}

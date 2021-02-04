//
//  CategorySelection.swift
//  PizzaApp
//
//  Created by Léon Becker on 04.02.21.
//

import SwiftUI

struct CategorySelectionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding([.top, .bottom], 4)
            .padding([.leading, .trailing], 8)
            .background(Color.blue)
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.black, lineWidth: 2)
            )
            .cornerRadius(6)
            .shadow(radius: 3)
    }
}

struct CategorySelection: View {
    @Binding var selectedCategory: Int
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 15) {
                Button(action: {
                    selectedCategory = 0
                }) {
                    Text("Pizza")
                }
                Button(action: {
                    selectedCategory = 1
                }) {
                    Text("Eis & Dessert")
                }
            }
            .buttonStyle(CategorySelectionButtonStyle())
        }
        .padding([.leading, .trailing], 16)
    }
}

struct CategorySelection_Previews: PreviewProvider {
    static var previews: some View {
        CategorySelection(selectedCategory: .constant(1))
    }
}

//
//  CategoryView.swift
//  PizzaTech
//
//  Created by Léon Becker on 05.03.21.
//

import SwiftUI

struct CategoryView: View {
    var body: some View {
        VStack(spacing: 13) {
            CategorySelection()
            SelectedCategory()
        }
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView()
            .modifier(PizzaTechServices())
            
    }
}

//
//  CategoryView.swift
//  PizzaTech
//
//  Created by Léon Becker on 05.03.21.
//

import SwiftUI

struct CatalogView: View {
    var body: some View {
        VStack(spacing: 13) {
            CategorySelection()
            SelectedCategory()
        }
    }
}

struct CatalogView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogView()
            .modifier(PizzaTechServices())
            
    }
}

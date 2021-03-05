//
//  CurrentCategory.swift
//  PizzaTech
//
//  Created by Léon Becker on 06.03.21.
//

import SwiftUI

struct CurrentCategory: View {
    @EnvironmentObject var catalogService: CatalogService
    
    var body: some View {
        VStack {
            Text(String(catalogService.categorySelection))
        }
    }
}

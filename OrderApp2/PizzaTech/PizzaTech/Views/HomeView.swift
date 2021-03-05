//
//  ContentView.swift
//  PizzaTech
//
//  Created by Léon Becker on 05.03.21.
//

import SwiftUI
import CoreData


struct HomeView: View {
    @EnvironmentObject var catalogService: CatalogService
    
    var body: some View {
        NavigationView {
            Group {
                HomeActionView()
                // CatalogView()
            }
            .navigationBarTitle("Pizza Tech")
        }
        .onAppear { catalogService.startDownload() }
        // Will hide inline navigation bar when other view linked here.
        .navigationBarHidden(true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(CatalogService())
    }
}

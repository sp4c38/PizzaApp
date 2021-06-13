//
//  ContentView.swift
//  PizzaTech
//
//  Created by Léon Becker on 05.03.21.
//

import SwiftUI
import CoreData

struct ThanksForOrder: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Danke!")
                .bold()
                .font(.title)
                .foregroundColor(.white)
            Text("Unter \"Bestellungen\" können Sie den Fortschritt Ihrer Bestellung verfolgen.")
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding([.leading, .trailing])
                .padding([.top, .bottom], 20)
                .background(Color.red.cornerRadius(20).shadow(radius: 10))
                .padding([.leading, .trailing], 10)
        }
        .frame(maxWidth: .infinity)
        .padding([.top, .bottom], 20)
        .background(Color.red.cornerRadius(20).shadow(radius: 10))
        .padding([.leading, .trailing])
    }
}

struct HomeView: View {
    @EnvironmentObject var catalogService: CatalogService
    
    var body: some View {
        NavigationView {
            Group {
                if catalogService.catalog != nil {
                    ScrollView {
                        VStack(spacing: 30) {
                            MainActionsView()
                            
                            if catalogService.showThanksForOrder {
                                ThanksForOrder()
                            }
                            
                            CatalogView()
                        }
                    }
                    .padding(.top, 5)
                }
            }
            .navigationBarTitle("Pizza Tech")
        }
        .onAppear { catalogService.fetchCatalog() }
        // Will hide inline navigation bar when other view linked here.
        .navigationBarHidden(true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ThanksForOrder()
//        HomeView()
//            .environmentObject(CatalogService())
    }
}

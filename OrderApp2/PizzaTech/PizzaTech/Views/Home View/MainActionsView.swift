//
//  MainActionsView.swift
//  PizzaTech
//
//  Created by Léon Becker on 05.03.21.
//

import SwiftUI

struct MainActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .multilineTextAlignment(.center)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            
            .background(Color.red)
            .cornerRadius(10)
            .shadow(color: .gray, radius: 5, x: -1, y: 2)
    }
}

struct MainActionsView: View {
    @State var isActive1 = false
    @State var isActive2 = false
    var body: some View {
        HStack(spacing: 13) {
            NavigationLink(destination: RealOrderView(), isActive: $isActive2) {
                Button(action: {
                    isActive2 = true
                }) {
                    HStack {
                        Text("Bestellungen")
                            .font(.caption)
                        Image(systemName: "archivebox")
                    }
                }
                .buttonStyle(MainActionButtonStyle())
            }
            
            NavigationLink(destination: OrderView(), isActive: $isActive1) {
                Button(action: {
                    isActive1 = true
                }) {
                    HStack {
                        Image(systemName: "cart")
                        Text("Warenkorb")
                            .font(.caption)
                        
                    }
                }
                .buttonStyle(MainActionButtonStyle())
            }
        }
        .padding([.leading, .trailing], 16)
    }
}

struct MainActionsView_Previews: PreviewProvider {
    static var previews: some View {
        MainActionsView()
    }
}

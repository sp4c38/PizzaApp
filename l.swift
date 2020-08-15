//
//  l.swift
//  PizzaApp
//
//  Created by Léon Becker on 15.08.20.
//

import SwiftUI

struct l: View {
    @State private var showDetails = false

    var body: some View {
        VStack {
            Button(action: {
                withAnimation {
                    self.showDetails.toggle()
                }
            }) {
                Text("Tap to show details")
            }

            if showDetails {
                Text("Details go here.")
            }
        }
    }
}

struct l_Previews: PreviewProvider {
    static var previews: some View {
        l()
    }
}

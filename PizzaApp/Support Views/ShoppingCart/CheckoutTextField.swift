//
//  CheckoutTextField.swift
//  PizzaApp
//
//  Created by Léon Becker on 17.08.20.
//

import SwiftUI

struct CheckoutTextField: UIViewRepresentable {
    // Need to use a UIViewRepresentable because need to change some extra attributes of the TextField which cannot yet be managed by SwiftUI
    
    func makeUIView(context: Context) -> some UITextField {
        return UITextField()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

struct CheckoutTextField_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView()
    }
}

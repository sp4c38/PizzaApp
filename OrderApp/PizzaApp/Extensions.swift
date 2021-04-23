//
//  Extensions.swift
//  PizzaApp
//
//  Created by Léon Becker on 05.02.21.
//

import SwiftUI

extension View {
    @ViewBuilder func ifTrue<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        } else {
            self
        }
    }
}

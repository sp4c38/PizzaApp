//
//  KeyboardResponder.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 25.08.20.
//

import Foundation
import SwiftUI

class KeyboardResponder: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    var center: NotificationCenter
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            withAnimation(.easeInOut(duration: 0.5)) {
                keyboardHeight = keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        withAnimation(.easeInOut(duration: 0.5)) {
            keyboardHeight = 0
        }
    }
    
    init(center: NotificationCenter = NotificationCenter.default) {
        self.center = center
        
        self.center.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
    
        self.center.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
}

//
//  DeleteOrder.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 27.08.20.
//

import Foundation

func deleteOrder(orderId: Int, username: String, keychainStore: KeychainStore) {
    let checkLoginUrl = URL(string: "https://www.space8.me:7392/pizzaapp/delete_order")
    
    let password = checkGetPasswordStored(username: username, keychainStore: keychainStore)
    
    if password != nil {
        let jsonEncoder = JSONEncoder()
        
        var request = URLRequest(url: checkLoginUrl!)
        
        request.httpMethod = "POST"
        let encodedAuthData = "\(username):\(password!)".data(using: .utf8)!.base64EncodedString()
        request.addValue("Basic \(encodedAuthData)", forHTTPHeaderField: "Authorization")
        
        struct OrderIdDeletionBody: Codable {
            var pizza_order_id: Int
        }
        
        let orderIdDeletion = OrderIdDeletionBody(pizza_order_id: orderId)
        var orderIdDeletionBody: Data
        
        do {
            orderIdDeletionBody = try jsonEncoder.encode(orderIdDeletion)
        } catch {
            fatalError("Couldn't encode the json which includes the order id to delete an order. \(error)")
        }
        
        request.httpBody = orderIdDeletionBody
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let checkTask = URLSession.shared.dataTask(with: request) { data, response, error in
            semaphore.signal()
        }
        
        checkTask.resume()
        semaphore.wait()
        
        print("Deleted the order.")
    } else {
        // Log out here because there is no password stored. This shouldn't happen because there is a username stored but no password. On startup the app also checks if the login details are still valid.
    }
}

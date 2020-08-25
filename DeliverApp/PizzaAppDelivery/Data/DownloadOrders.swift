//
//  Networking.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 21.08.20.
//

import SwiftUI

struct SinglePizzaOrdered: Codable, Hashable {
    var pizzaId: Int32
    var sizeIndex: Int16
}

struct SingleOrder: Codable, Hashable {
    var firstname: String
    var lastname: String
    var street: String
    var postalCode: Int32
    var city: String
    var paymentMethod: Int8
    var pizzasOrdered: [SinglePizzaOrdered]
}

struct OrderData: Codable {
    var request_successful: Bool
    var orders: [SingleOrder]
}

func downloadOrders(username: String, keychainStore: KeychainStore) -> OrderData {
    var request = URLRequest(url: URL(string: "https://www.space8.me:7392/pizzaapp/get_all_orders")!)
    
    let password = checkGetPasswordStored(username: username, keychainStore: keychainStore)
    
    var responseData: OrderData?
    
    if password != nil {
        request.httpMethod = "POST"
        
        let encodedAuthData = "\(username):\(password!)".data(using: .utf8)!.base64EncodedString()
        request.setValue("Basic \(encodedAuthData)", forHTTPHeaderField: "Authorization")

        let semaphore = DispatchSemaphore(value: 0)
        
        let downloadTask = URLSession.shared.dataTask(with: request) { data, response, error in
            let jsonDecoder = JSONDecoder()
            
            do {
                responseData = try jsonDecoder.decode(OrderData.self, from: data!)
            } catch {
                fatalError("Couldn't download orders. \(error)")
            }
            
            semaphore.signal()
        }

        downloadTask.resume()
        semaphore.wait()
    } else {
        // Log out here because there is no password stored. This shouldn't happen because there is a username stored but no password. On startup the app also checks if the login details are still valid.
    }
    
    return responseData!
}

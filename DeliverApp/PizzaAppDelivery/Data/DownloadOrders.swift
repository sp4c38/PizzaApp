//
//  Networking.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 21.08.20.
//

import SwiftUI

func downloadOrders(username: String, keychainStore: KeychainStore) -> Bool {
    var request = URLRequest(url: URL(string: "https://www.space8.me:7392/pizzaapp/get_all_orders")!)
    
    let password = checkGetPasswordStored(username: username, keychainStore: keychainStore)
    
    if password != nil {
        request.httpMethod = "POST"
        
        let encodedAuthData = "\(username):\(password!)".data(using: .utf8)!.base64EncodedString()
        request.setValue("Basic \(encodedAuthData)", forHTTPHeaderField: "Authorization")

        let semaphore = DispatchSemaphore(value: 0)

        let downloadTask = URLSession.shared.dataTask(with: request) { data, response, error in
            print(String(data: data!, encoding: .utf8)!)
            semaphore.signal()
        }

        downloadTask.resume()
        semaphore.wait()
    }
    
    return true
}

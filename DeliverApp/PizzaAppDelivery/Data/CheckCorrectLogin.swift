//
//  CheckCorrectLogin.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 22.08.20.
//

import SwiftUI

func checkCorrectLogin(username: String, password: String) -> Bool {
    let checkLoginUrl = URL(string: "https://www.space8.me:7392/pizzaapp/login0593090539212/onlycheck")
    var request = URLRequest(url: checkLoginUrl!)
    
    struct LoginCollection: Codable {
        let username: String
        let password: String
    }
    
    let loginCollection = LoginCollection(username: username, password: password)
    let jsonEncoder = JSONEncoder()
    let loginCollectionData: Data
    
    do {
        loginCollectionData = try jsonEncoder.encode(loginCollection)
    } catch {
        fatalError("Error encoding loginCollectionData \(error).")
    }
    
    request.httpBody = loginCollectionData
    
    let semaphore = DispatchSemaphore(value: 0)
    
    let checkTask = URLSession.shared.dataTask(with: request) { data, response, error in
        
    }
    
    return false
}

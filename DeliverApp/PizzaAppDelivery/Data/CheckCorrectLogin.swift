//
//  CheckCorrectLogin.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 22.08.20.
//

import SwiftUI

func checkCorrectLogin(username: String, password: String) -> Bool {
    let checkLoginUrl = URL(string: "https://www.space8.me:7392/pizzaapp/login/onlycheck")
    var request = URLRequest(url: checkLoginUrl!)
    
    request.httpMethod = "POST"
    let encodedAuthData = "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
    request.addValue("Basic \(encodedAuthData)", forHTTPHeaderField: "Authorization")
    
    let semaphore = DispatchSemaphore(value: 0)
    
    struct loginExistsReturn: Codable {
        var user_exists: Bool
    }
    
    var loginExists = false
    
    let checkTask = URLSession.shared.dataTask(with: request) { data, response, error in
        let jsonDecoder = JSONDecoder()
        var loginExistsReturnData: loginExistsReturn
        
        do {
            print(String(data: data!, encoding: .utf8)!)
            loginExistsReturnData = try jsonDecoder.decode(loginExistsReturn.self, from: data!)
        } catch {
            fatalError("Couldn't parse return JSON data from server while checking if the user exists. \(error)")
        }
        
        if loginExistsReturnData.user_exists == true {
            loginExists = true
        }
        
        semaphore.signal()
    }
    
    checkTask.resume()
    semaphore.wait()
    
    return loginExists
}

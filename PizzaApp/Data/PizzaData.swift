//
//  PizzaData.swift
//  PizzaApp
//
//  Created by Léon Becker on 13.08.20.
//

import Foundation
import UIKit
import SwiftUI

struct Pizza: Codable, Hashable {
    var name: String
    var prices: [Double]
    fileprivate var imageName: String
    var image: Image {
        Image(imageName)
    }
    var ingredientDescription: String
}

struct PizzaInfo: Codable {
    var info: [String: [String]]
    var pizzas: [Pizza]
}

func downloadPizzaData(url: String) -> PizzaInfo {
    // Download pizza data from the server
    // This will run synchronous because this data is absolutely needed to continue the workflow of the program
    
    var request = URLRequest(url: URL(string: url)!)
    request.httpMethod = "GET"
    
    // Parameters to pass
    request.httpBody = "".data(using: .utf8)
    
    let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
    var outputData: PizzaInfo?
        
    let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
        if let error = error {
            print("Error occurred when retrieving data: \(error)")
            return
        }
        
        let jsonDecoder = JSONDecoder()
        if let data = data {
            do {
                print(String(data: data, encoding: .utf8)!)
                let jsonDict = try jsonDecoder.decode(PizzaInfo.self, from: data)
                outputData = jsonDict
            } catch {
                print("Couldn't parse Pizza Info JSON Data. Error: \(error)")
            }
            
            semaphore.signal()
        }
    })
    
    task.resume()
    semaphore.wait()
    
    return outputData!
}

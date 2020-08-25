//
//  PizzaCatalog.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 25.08.20.
//

import SwiftUI
import Foundation

var pizzaCatalog = downloadPizzaCatalog(url: "https://www.space8.me:7392/pizzaapp/static/allPizzas.json")

struct Pizza: Codable {
    var id: Int32
    var name: String
    var imageName: String
    var image: Image {
        Image(imageName)
    }
    var prices: [Double]
    var ingredientDescription: String
}

struct CatalogInfo: Codable {
    var info: [String: [String]]
    var pizzas: [Pizza]
}

func downloadPizzaCatalog(url: String) -> CatalogInfo {
    // Download pizza data from the server
    // This will run synchronous because this data is absolutely needed to continue the workflow of the program
    
    var request = URLRequest(url: URL(string: url)!)
    request.httpMethod = "GET"
    
    // Parameters to pass
    request.httpBody = "".data(using: .utf8)
    
    let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
    var outputData: CatalogInfo?
        
    let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
        if let error = error {
            fatalError("Error occurred when retrieving data: \(error)")
        }
        
        let jsonDecoder = JSONDecoder()
        if let data = data {
            do {
                let jsonDict = try jsonDecoder.decode(CatalogInfo.self, from: data)
                outputData = jsonDict
            } catch {
                fatalError("Couldn't parse Pizza Info JSON Data. Error: \(error)")
            }
            
            semaphore.signal()
        }
    })
    
    task.resume()
    semaphore.wait()
    
    return outputData!
}

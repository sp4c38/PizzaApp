//
//  PizzaCatalog.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 25.08.20.
//

import Foundation

var PizzaData: PizzaInfo = downloadPizzaData(url: "https://www.space8.me/resources/allPizzas.json")

func downloadPizzaCatalog(url: String) -> PizzaInfo {
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
            fatalError("Error occurred when retrieving data: \(error)")
        }
        
        let jsonDecoder = JSONDecoder()
        if let data = data {
            do {
                let jsonDict = try jsonDecoder.decode(PizzaInfo.self, from: data)
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

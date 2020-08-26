//
//  Networking.swift
//  PizzaApp
//
//  Created by Léon Becker on 17.08.20.
//

import Foundation

func downloadPizzaData(url: String) -> CatalogInfo {
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

func sendPizzaOrder(_ url: String, shoppingCartItems: [ShoppingCartItem], orderDetails: OrderDetails) -> Bool {
    let orderDestination = URL(string: url)
    
    var request = URLRequest(url: orderDestination!)
    request.httpMethod = "POST"
    
    struct bodyData: Encodable {
        var firstname: String
        var lastname: String
        var street: String
        var city: String
        var postalcode: Int32
        var pizzas = [[String: Int]]()
        var payment_method: Int8
        
        init(_ orderDetails: OrderDetails, _ shoppingCart: [ShoppingCartItem]) {
            self.firstname = orderDetails.firstname
            self.lastname = orderDetails.lastname
            self.street = orderDetails.street
            self.city = orderDetails.city
            self.postalcode = Int32(orderDetails.postalCode)!
            self.payment_method = orderDetails.selectedPaymentMethod
            
            for pizza in shoppingCart {
                self.pizzas.append(["pizza_id": Int(pizza.pizzaId), "pizza_sizeindex": Int(pizza.sizeIndex)])
            }
        }
    }
    
    let body = bodyData(orderDetails, shoppingCartItems)

    let jsonEncoder = JSONEncoder()
    var encodedData: Data
    
    do {
        encodedData = try jsonEncoder.encode(body)
    } catch {
        fatalError("Error encoding the dictionary into JSON which will be sent to the server. Error: \(error)")
    }
    
    var MadeSuccessfulRequest: Bool = false // Is set to true if the request was successful
    request.httpBody = encodedData
    
    let semaphore = DispatchSemaphore(value: 0)

    struct returnSucceeded: Decodable {
        var request_successful: Bool
    }
    
    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
        let jsonDecoder = JSONDecoder()
        var successfulRequest: returnSucceeded
        
        do {
            print(String(data: data!, encoding: .utf8)!)
            successfulRequest = try jsonDecoder.decode(returnSucceeded.self, from: data!)
        } catch {
            fatalError("Error parsing the returned JSON data returned from the server after sending order. Error: \(error)")
        }
        
        if successfulRequest.request_successful == true {
            MadeSuccessfulRequest = true
        }

        semaphore.signal()
    })

    task.resume()
    semaphore.wait()
    
    return MadeSuccessfulRequest
}

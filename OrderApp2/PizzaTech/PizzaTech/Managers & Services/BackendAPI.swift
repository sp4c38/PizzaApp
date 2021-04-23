//
//  API.swift
//  PizzaTech
//
//  Created by Léon Becker on 05.03.21.
//

import Foundation

struct BackendAPI {
    static var downloadCatalogURL = getURL(
        resource: "https://www.space8.me:7392/pizzaapp/static/catalog.json"
    )
    
    private static func getURL(resource: String) -> URL {
        let url = URL(string: resource)
        
        if url != nil {
            return url!
        } else {
            fatalError("Backend access API URL is not valid format: \(resource).")
        }
    }
}

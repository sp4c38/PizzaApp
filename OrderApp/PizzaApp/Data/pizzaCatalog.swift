//
//  PizzaData.swift
//  PizzaApp
//
//  Created by Léon Becker on 13.08.20.
//

import Foundation
import SwiftUI

var PizzaCatalog: CatalogInfo = downloadPizzaData(url: "https://www.space8.me:7392/pizzaapp/static/allPizzas.json")

struct Pizza: Codable, Hashable {
    var id: Int32
    var name: String
    var imageName: String
    var image: Image {
        Image(imageName)
    }
    var prices: [Double]
    var ingredientDescription: String
    var vegetarian: Bool
    var vegan: Bool
    var spicy: Bool
}

struct CatalogInfo: Codable {
    var info: [String: [String]]
    var pizzas: [Pizza]
}


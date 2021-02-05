//
//  Catalog.swift
//  PizzaApp
//
//  Created by Léon Becker on 13.08.20.
//

import Foundation
import SwiftUI

let catalog = downloadCatalogData(url: "https://www.space8.me:7392/pizzaapp/static/catalog.json")

protocol CatalogItem: Codable, Hashable {
    var id: Int32 { get set }
    var name: String { get set }
    var imageName: String { get set }
    var ingredientDescription: String { get set }
}

struct Pizza: CatalogItem {
    var id: Int32
    var name: String
    var imageName: String
    var ingredientDescription: String
    var prices: [Double]
    var vegetarian: Bool
    var vegan: Bool
    var spicy: Bool
}

struct IceAndDessert: CatalogItem {
    var id: Int32
    var name: String
    var imageName: String
    var ingredientDescription: String
    var price: Double
    var vegan: Bool
}

struct CatalogInfo: Codable {
    var info: [String: [String]]
    var pizzas: [Pizza]
    var iceAndDessert: [IceAndDessert]
}


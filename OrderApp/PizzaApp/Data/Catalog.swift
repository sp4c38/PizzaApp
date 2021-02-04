//
//  Catalog.swift
//  PizzaApp
//
//  Created by Léon Becker on 13.08.20.
//

import Foundation
import SwiftUI

let catalog = downloadCatalogData(url: "https://www.space8.me:7392/pizzaapp/static/catalog.json")

protocol CatalogItem: Hashable {
    var id: Int32 { get set }
    var name: String { get set }
    var imageName: String { get set }
}

struct Pizza: CatalogItem, Codable {
    var id: Int32
    var name: String
    var imageName: String
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


//
//  CatalogService.swift
//  PizzaTech
//
//  Created by Léon Becker on 05.03.21.
//

import Foundation

// Category items
protocol CatalogGeneralItem: Codable {
    var id: Int { get set }
    var name: String { get set }
    var imageName: String { get set }
    var prices: [Float] { get set }
    var ingredientDescription: String { get set }
}

class IceDessertItem: CatalogGeneralItem {
    var id: Int
    var name: String
    var imageName: String
    
    var prices: [Float]
    var ingredientDescription: String
}

class PizzaItem: CatalogGeneralItem {
    var id: Int
    var name: String
    var imageName: String
    
    var prices: [Float]
    var ingredientDescription: String
    
    var vegetarian: Bool
    var vegan: Bool
    var spicy: Bool
}

// Categories
protocol CatalogGeneralCategory: Codable {
    associatedtype CatalogGeneralItem
    
    var items: [CatalogGeneralItem] { get set }
}

class PizzaCategory: CatalogGeneralCategory {
    var items: [PizzaItem]
}

class IceDessertCategory: CatalogGeneralCategory {
    var items: [IceDessertItem]
}

// Catalog
struct Catalog: Codable {
    let pizzas: PizzaCategory
    let iceAndDessert: IceDessertCategory
}

class CatalogService: ObservableObject {
    var catalog: Catalog? = nil
    var downloadInProgress = false
    var downloadErrorOccurred = false
}

//
//  CatalogItems.swift
//  PizzaTech
//
//  Created by Léon Becker on 06.03.21.
//

import Foundation

class PizzaItem: CatalogGeneralItem, CatalogFoodCharacteristics {
    var id: Int
    var name: String
    var imageName: String
    var prices: [Float]
    var ingredientDescription: String
    
    var vegetarian: Bool
    var vegan: Bool
    var spicy: Bool
}

class BurgerItem: CatalogGeneralItem, CatalogFoodCharacteristics {
    var id: Int
    var name: String
    var imageName: String
    var prices: [Float]
    var ingredientDescription: String
    
    var vegetarian: Bool
    var vegan: Bool
    var spicy: Bool
}

class SaladItem: CatalogGeneralItem, CatalogFoodCharacteristics {
    var id: Int
    var name: String
    var imageName: String
    var prices: [Float]
    var ingredientDescription: String
    
    var vegetarian: Bool
    var vegan: Bool
    var spicy: Bool
}

class IceDessertItem: CatalogGeneralItem {
    var id: Int
    var name: String
    var imageName: String
    var prices: [Float]
    var ingredientDescription: String
}

class DrinkItem: CatalogGeneralItem {
    var id: Int
    var name: String
    var imageName: String
    var prices: [Float]
    var ingredientDescription: String
}

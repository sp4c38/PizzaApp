//
//  CatalogCategories.swift
//  PizzaTech
//
//  Created by Léon Becker on 06.03.21.
//

import Foundation

struct FoodCharacteristics: CatalogFoodCharacteristics {
    var vegetarian: Bool
    var vegan: Bool
    var spicy: Bool
}

struct PizzaItem: CatalogGeneralItem {
    var id: Int
    var name: String
    var imageName: String
    var prices: [Float]
    var ingredientDescription: String
    var speciality: FoodCharacteristics
    
    enum CodingKeys: String, CodingKey {
        case id, name, prices, speciality
        case imageName = "image_name"
        case ingredientDescription = "ingredient_description"
    }
}

class PizzaCategory: CatalogGeneralCategory {
    var items: [PizzaItem]
    
    enum CodingKeys: String, CodingKey {
        case items = "all_items"
    }
}

struct BurgerItem: CatalogGeneralItem {
    var id: Int
    var name: String
    var imageName: String
    var prices: [Float]
    var ingredientDescription: String
    var speciality: FoodCharacteristics
    
    enum CodingKeys: String, CodingKey {
        case id, name, prices, speciality
        case imageName = "image_name"
        case ingredientDescription = "ingredient_description"
    }
}

struct BurgerCategory: CatalogGeneralCategory {
    var items: [BurgerItem]
    
    enum CodingKeys: String, CodingKey {
        case items = "all_items"
    }
}

struct SaladItem: CatalogGeneralItem {
    var id: Int
    var name: String
    var imageName: String
    var prices: [Float]
    var ingredientDescription: String
    var speciality: FoodCharacteristics
    
    enum CodingKeys: String, CodingKey {
        case id, name, prices, speciality
        case imageName = "image_name"
        case ingredientDescription = "ingredient_description"
    }
}

struct SaladCategory: CatalogGeneralCategory {
    var items: [SaladItem]
    
    enum CodingKeys: String, CodingKey {
        case items = "all_items"
    }
}

struct PastaItem: CatalogGeneralItem {
    var id: Int
    var name: String
    var imageName: String
    var prices: [Float]
    var ingredientDescription: String
    var speciality: FoodCharacteristics
    
    enum CodingKeys: String, CodingKey {
        case id, name, prices, speciality
        case imageName = "image_name"
        case ingredientDescription = "ingredient_description"
    }
}

struct PastaCategory: CatalogGeneralCategory {
    var items: [PastaItem]
    
    enum CodingKeys: String, CodingKey {
        case items = "all_items"
    }
}

struct IceDessertItem: CatalogGeneralItem {
    var id: Int
    var name: String
    var imageName: String
    var prices: [Float]
    var ingredientDescription: String
    var speciality: FoodCharacteristics
    
    enum CodingKeys: String, CodingKey {
        case id, name, prices, speciality
        case imageName = "image_name"
        case ingredientDescription = "ingredient_description"
    }
}

struct IceDessertCategory: CatalogGeneralCategory {
    var items: [IceDessertItem]
    
    enum CodingKeys: String, CodingKey {
        case items = "all_items"
    }
}

struct DrinkItem: CatalogGeneralItem {
    var id: Int
    var name: String
    var imageName: String
    var prices: [Float]
    var ingredientDescription: String
    var speciality: FoodCharacteristics
    
    enum CodingKeys: String, CodingKey {
        case id, name, prices, speciality
        case imageName = "image_name"
        case ingredientDescription = "ingredient_description"
    }
}

struct DrinkCategory: CatalogGeneralCategory {
    var items: [DrinkItem]
    
    enum CodingKeys: String, CodingKey {
        case items = "all_items"
    }
}

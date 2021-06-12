//
//  CatalogCategories.swift
//  PizzaTech
//
//  Created by Léon Becker on 06.03.21.
//

import Foundation

class FoodCharacteristics: CatalogFoodCharacteristics {
    var vegetarian: Bool
    var vegan: Bool
    var spicy: Bool
}

class PizzaItem: CatalogGeneralItem {
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

class BurgerItem: CatalogGeneralItem {
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

class BurgerCategory: CatalogGeneralCategory {
    var items: [BurgerItem]
    
    enum CodingKeys: String, CodingKey {
        case items = "all_items"
    }
}

class SaladItem: CatalogGeneralItem {
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

class SaladCategory: CatalogGeneralCategory {
    var items: [SaladItem]
    
    enum CodingKeys: String, CodingKey {
        case items = "all_items"
    }
}

class PastaItem: CatalogGeneralItem {
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

class PastaCategory: CatalogGeneralCategory {
    var items: [PastaItem]
    
    enum CodingKeys: String, CodingKey {
        case items = "all_items"
    }
}

class IceDessertItem: CatalogGeneralItem {
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

class IceDessertCategory: CatalogGeneralCategory {
    var items: [IceDessertItem]
    
    enum CodingKeys: String, CodingKey {
        case items = "all_items"
    }
}

class DrinkItem: CatalogGeneralItem {
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

class DrinkCategory: CatalogGeneralCategory {
    var items: [DrinkItem]
    
    enum CodingKeys: String, CodingKey {
        case items = "all_items"
    }
}

//
//  CatalogService.swift
//  PizzaTech
//
//  Created by Léon Becker on 05.03.21.
//

import Foundation

protocol CatalogFoodCharacteristics: Codable {
    var vegetarian: Bool { get }
    var vegan: Bool { get }
    var spicy: Bool { get }
}

protocol CatalogGeneralItem: Codable {
    var id: Int { get }
    var name: String { get }
    var imageName: String { get }
    var prices: [Float] { get }
    var ingredientDescription: String { get }
    var speciality: FoodCharacteristics { get }
}

protocol CatalogGeneralCategory: Codable {
    associatedtype CatalogGeneralItem
    
    var items: [CatalogGeneralItem] { get }
}

enum CategoryID {
    case pizza, burger, salad, pasta, iceDessert, drink
    
    var id: Int {
        switch self {
        case .pizza:
            return 0
        case .burger:
            return 1
        case .salad:
            return 2
        case .pasta:
            return 3
        case .iceDessert:
            return 4
        case .drink:
            return 5
        }
    }
    
    var name: String {
        switch self {
        case .pizza:
            return "Pizza"
        case .burger:
            return "Burger"
        case .salad:
            return "Salat"
        case .pasta:
            return "Pasta"
        case .iceDessert:
            return "Eis & Dessert"
        case .drink:
            return "Getränke"
        }
    }
}

struct Categories: Codable {
    var pizza: PizzaCategory
    var burger: BurgerCategory
    var salad: SaladCategory
    var pasta: PastaCategory
    var iceDessert: IceDessertCategory
    var drink: DrinkCategory
    
    let categoryID: [CategoryID] = [.pizza, .drink, .burger, .salad, .iceDessert, .pasta]
    
    enum CodingKeys: String, CodingKey {
        case iceDessert = "ice_dessert"
        case pizza, burger, salad, pasta, drink
    }
}

// Catalog
struct Catalog: Codable {
    var categories: Categories
}

class CatalogService: ObservableObject {
    @Published var catalog: Catalog? = nil
    
    @Published var categorySelection: CategoryID = .pizza
    
    func fetchCatalog() {
        catalog = loadPreviewJSON("CatalogPreview")
    }
}

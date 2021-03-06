//
//  CatalogService.swift
//  PizzaTech
//
//  Created by Léon Becker on 05.03.21.
//

import Foundation

protocol CatalogFoodCharacteristics {
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
}

protocol CatalogGeneralCategory: Codable {
    associatedtype CatalogGeneralItem
    
    var sizeNames: [String] { get }
    var items: [CatalogGeneralItem] { get }
}

enum CategoryID {
    case pizza, burger, salad, iceDessert, drink
    
    var identification: Int {
        switch self {
        case .pizza:
            return 0
        case .burger:
            return 1
        case .salad:
            return 2
        case .iceDessert:
            return 3
        case .drink:
            return 4
        }
    }
    
    var name: String {
        switch self {
        case .pizza:
            return "Pizza"
        case .burger:
            return "Burger"
        case .salad:
            return "Salad"
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
    var iceDessert: IceDessertCategory
    var drink: DrinkCategory
    
    let categoryID: [CategoryID] = [.pizza, .burger, .salad, .iceDessert, .drink]
    
    enum CodingKeys: CodingKey {
        case pizza, burger, salad, iceDessert, drink
    }
}

// Catalog
struct Catalog: Codable {
    var categories: Categories
}

class CatalogService: ObservableObject {
    @Published var catalog: Catalog? = nil
    @Published var downloadInProgress = false
    @Published var downloadErrorOccurred = false
    
    @Published var categorySelection: CategoryID = .pizza
}

extension CatalogService {
    func setCategorySelection(to newCategory: CategoryID) {
        self.categorySelection = newCategory
    }
}

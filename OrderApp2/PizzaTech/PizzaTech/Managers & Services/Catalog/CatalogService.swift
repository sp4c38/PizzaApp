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
    
    var name: String { get set }
    var sizeNames: [String] { get set }
    var items: [CatalogGeneralItem] { get set }
}

class PizzaCategory: CatalogGeneralCategory {
    var name: String
    var sizeNames: [String]
    var items: [PizzaItem]
}

class IceDessertCategory: CatalogGeneralCategory {
    var name: String
    var sizeNames: [String]
    var items: [IceDessertItem]
}

enum CategoryID: Int {
    case pizza = 1
    case iceDessert = 2
}

struct Categories: Codable {
    var pizza: PizzaCategory
    var iceDessert: IceDessertCategory
    
    let categoryIDs: [CategoryID] = [.pizza, .iceDessert]
    
    enum CodingKeys: CodingKey {
        case pizza
        case iceDessert
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

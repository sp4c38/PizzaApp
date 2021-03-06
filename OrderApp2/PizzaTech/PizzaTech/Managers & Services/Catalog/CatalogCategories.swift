//
//  CatalogCategories.swift
//  PizzaTech
//
//  Created by Léon Becker on 06.03.21.
//

import Foundation

class PizzaCategory: CatalogGeneralCategory {
    var sizeNames: [String]
    var items: [PizzaItem]
}

class BurgerCategory: CatalogGeneralCategory {
    var sizeNames: [String]
    var items: [BurgerItem]
}

class SaladCategory: CatalogGeneralCategory {
    var sizeNames: [String]
    var items: [SaladItem]
}

class IceDessertCategory: CatalogGeneralCategory {
    var sizeNames: [String]
    var items: [IceDessertItem]
}

class DrinkCategory: CatalogGeneralCategory {
    var sizeNames: [String]
    var items: [DrinkItem]
}

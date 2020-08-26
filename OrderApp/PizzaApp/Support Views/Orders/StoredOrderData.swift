//
//  StoredOrderData.swift
//  PizzaApp
//
//  Created by Léon Becker on 26.08.20.
//

import Foundation

struct StoredOrderedPizza: Codable {
    var pizzaId: Int32
    var pizzaSizeIndex: Int16
}

struct StoredOrderData: Codable {
    var allStoredPizzas: [StoredOrderedPizza]
}

//
//  PizzaData.swift
//  PizzaApp
//
//  Created by Léon Becker on 13.08.20.
//

import Foundation
import UIKit
import SwiftUI

struct Pizza: Codable, Hashable {
    var id: Int32
    var name: String
    var imageName: String
    var image: Image {
        Image(imageName)
    }
    var prices: [Double]
    var ingredientDescription: String
}

struct PizzaInfo: Codable {
    var info: [String: [String]]
    var pizzas: [Pizza]
}


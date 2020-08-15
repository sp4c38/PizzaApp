//
//  ShoppingCart+CoreDataProperties.swift
//  PizzaApp
//
//  Created by Léon Becker on 15.08.20.
//
//

import Foundation
import CoreData


extension ShoppingCart: Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShoppingCart> {
        return NSFetchRequest<ShoppingCart>(entityName: "ShoppingCart")
    }

    @NSManaged public var name: String
    @NSManaged public var size: String

}

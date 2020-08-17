//
//  ShoppingCart+CoreDataProperties.swift
//  PizzaApp
//
//  Created by Léon Becker on 15.08.20.
//
//

import Foundation
import CoreData


extension ShoppingCartItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShoppingCartItem> {
        return NSFetchRequest<ShoppingCartItem>(entityName: "ShoppingCart")
    }

    @NSManaged public var name: String
    @NSManaged public var sizeIndex: Int16
    @NSManaged public var pictureName: String

}

extension ShoppingCartItem : Identifiable {

}

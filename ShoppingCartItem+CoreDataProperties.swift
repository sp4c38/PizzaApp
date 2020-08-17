//
//  ShoppingCartItem+CoreDataProperties.swift
//  PizzaApp
//
//  Created by Léon Becker on 17.08.20.
//
//

import Foundation
import CoreData


extension ShoppingCartItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShoppingCartItem> {
        return NSFetchRequest<ShoppingCartItem>(entityName: "ShoppingCartItem")
    }

    @NSManaged public var name: String
    @NSManaged public var pictureName: String
    @NSManaged public var sizeIndex: Int16
    @NSManaged public var pizzaId: Int32
    @NSManaged public var price: Double

}

extension ShoppingCartItem : Identifiable {

}

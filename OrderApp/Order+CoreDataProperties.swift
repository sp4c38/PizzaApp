//
//  Order+CoreDataProperties.swift
//  PizzaApp
//
//  Created by Léon Becker on 26.08.20.
//
//

import Foundation
import CoreData


extension Order {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Order> {
        return NSFetchRequest<Order>(entityName: "Order")
    }

    @NSManaged public var pizzasOrdered: Data
    @NSManaged public var firstname: String
    @NSManaged public var lastname: String
    @NSManaged public var street: String
    @NSManaged public var postalCode: Int32
    @NSManaged public var city: String
    @NSManaged public var paymentMethod: Int16

}

extension Order : Identifiable {

}

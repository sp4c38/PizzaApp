//
//  RealOrder+CoreDataProperties.swift
//  PizzaTech
//
//  Created by Léon Becker on 13.06.21.
//
//

import Foundation
import CoreData


extension RealOrder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RealOrder> {
        return NSFetchRequest<RealOrder>(entityName: "RealOrder")
    }

    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var pizzasOrdered: Data?
    @NSManaged public var street: String?
    @NSManaged public var postalCode: String?
    @NSManaged public var city: String?
    @NSManaged public var orderID: Int64

}

extension RealOrder : Identifiable {

}

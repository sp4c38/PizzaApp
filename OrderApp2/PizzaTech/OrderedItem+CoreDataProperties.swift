//
//  OrderedItem+CoreDataProperties.swift
//  PizzaTech
//
//  Created by Léon Becker on 11.06.21.
//
//

import Foundation
import CoreData


extension OrderedItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OrderedItem> {
        return NSFetchRequest<OrderedItem>(entityName: "OrderedItem")
    }

    @NSManaged public var item_id: Int64
    @NSManaged public var quantity: Int64
    @NSManaged public var price: Double

}

extension OrderedItem : Identifiable {

}

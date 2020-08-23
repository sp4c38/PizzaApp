//
//  UserData+CoreDataProperties.swift
//  PizzaAppDelivery
//
//  Created by Léon Becker on 22.08.20.
//
//

import Foundation
import CoreData


extension UserData: Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserData> {
        return NSFetchRequest<UserData>(entityName: "UserData")
    }

    @NSManaged public var username: String

}

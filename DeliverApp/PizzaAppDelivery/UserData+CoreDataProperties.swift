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

    @nonobjc public class func userDataFetchRequest() -> NSFetchRequest<UserData> {
        let request: NSFetchRequest<UserData> = UserData.fetchRequest() as! NSFetchRequest<UserData>
        
        request.sortDescriptors = [NSSortDescriptor(key: "username", ascending: true)]
        
        return NSFetchRequest<UserData>(entityName: "UserData")
    }

    @NSManaged public var username: String

}

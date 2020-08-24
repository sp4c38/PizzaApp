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
        let request: NSFetchRequest<NSFetchRequestResult> = UserData.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(key: "username", ascending: true)]
        
        return NSFetchRequest<UserData>(entityName: "UserData")
    }

    @NSManaged public var username: String

}

// ❇️ BlogIdea code generation is turned OFF in the xcdatamodeld file
@objc(BlogIdea)
public class BlogIdea: NSManagedObject, Identifiable {
    @NSManaged public var ideaTitle: String?
    @NSManaged public var ideaDescription: String?
}

extension BlogIdea {
    // ❇️ The @FetchRequest property wrapper in the ContentView will call this function
    static func allIdeasFetchRequest() -> NSFetchRequest<BlogIdea> {
        let request: NSFetchRequest<BlogIdea> = BlogIdea.fetchRequest() as! NSFetchRequest<BlogIdea>
        
        // ❇️ The @FetchRequest property wrapper in the ContentView requires a sort descriptor
        request.sortDescriptors = [NSSortDescriptor(key: "ideaTitle", ascending: true)]
          
        return request
    }
}

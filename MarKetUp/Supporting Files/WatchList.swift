//
//  WatchList.swift
//  MarKetUp
//
//  Created by Sam Ding on 10/31/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import Foundation
import CoreData

public class WatchList: NSManagedObject{
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WatchList> {
        return NSFetchRequest<WatchList>(entityName: "WatchList")
    }
    
    @NSManaged public var symbol: String

}

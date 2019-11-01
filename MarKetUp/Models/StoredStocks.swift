//
//  StoredStocks.swift
//  MarKetUp
//
//  Created by Sam Ding on 10/30/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import Foundation
import CoreData

public class StoredStock: NSManagedObject{
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredStock> {
        return NSFetchRequest<StoredStock>(entityName: "StoredStock")
    }
    
    @NSManaged public var symbol: String
    @NSManaged public var buyingPrice: Float
    @NSManaged public var shares: Int32

    
}

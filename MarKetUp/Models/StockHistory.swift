//
//  StockHistory.swift
//  MarKetUp
//
//  Created by Sam Ding on 11/3/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import Foundation
import CoreData

public class StockHistory: NSManagedObject{
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<StockHistory> {
        return NSFetchRequest<StockHistory>(entityName: "StockHistory")
    }
    
    @NSManaged public var symbol: String
    @NSManaged public var type: String
    @NSManaged public var date: String
    @NSManaged public var price: Float
    @NSManaged public var shares: Int32
     @NSManaged public var time: String
    
    

}

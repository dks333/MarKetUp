//
//  User.swift
//  MarKetUp
//
//  Created by Sam Ding on 9/16/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import Foundation

struct User {
    var userId: String
    var cashes: Float
    var values: Float
    var ownedStocks: [Stocks]
    var watchList: [Stocks]
    
    init(userId: String, cashes: Float, values: Float, ownedStocks: [Stocks], watchList: [Stocks]){
        self.userId = userId
        self.cashes = cashes
        self.values = values
        self.ownedStocks = ownedStocks
        self.watchList = watchList
    }
    
    //Getting the toatal values that the user has in his/her account
    func getTotalValues() -> Float {
        return cashes + values
    }
    
    
    
}

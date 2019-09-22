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
    var ownedStocks: [Stock]
    var ownedStocksShares: [Stock:Int]
    var watchList: [Stock]
    

    init(userId: String, cashes: Float, values: Float, ownedStocks: [Stock], watchList: [Stock], ownedStocksShares: [Stock:Int]){
        self.userId = userId
        self.cashes = cashes
        self.values = values
        self.ownedStocks = ownedStocks
        self.watchList = watchList
        self.ownedStocksShares = ownedStocksShares
    }
    
    //Getting the toatal values that the user has in his/her account
    func getTotalValues() -> Float {
        return cashes + values
    }
    
    func isHeldStock(stock: Stock) -> Bool{
        return self.ownedStocks.contains(stock)
    }
    
    func addShareToStock(stock: Stock){
        
    }
    
    
    
    
    
}

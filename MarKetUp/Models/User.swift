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
    
    // fetch data to owned stocks
    mutating func setOwnedStock(stock: Stock){
        for i in 0..<self.ownedStocks.count{
            if ownedStocks[i] == stock {
                ownedStocks[i] = stock
            }
        }
    }
    
    //fetch data to current watchlist
    mutating func setWatchList(stock: Stock){
        for i in 0..<self.watchList.count{
            if watchList[i] == stock {
                watchList[i] = stock
            }
        }
    }
    
    func addShareToStock(stock: Stock){
        
    }
    
    mutating func addStocks(stock: Stock, type: String, index: Int){
        if !self.watchList.contains(stock) && !self.ownedStocks.contains(stock) {
            if type == "watchList" {
                // watchlist
                self.watchList.insert(stock, at: index)
            } else {
                //ownedStock
                self.ownedStocks.append(stock)
            }
        }
    }
    
    mutating func cancelFollowingStock(stock: Stock){
        if self.watchList.contains(stock){
            if let index = self.watchList.firstIndex(of: stock) {
                watchList.remove(at: index)
            }
        }
    }
    
    
    
    
    
}

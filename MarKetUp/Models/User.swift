//
//  User.swift
//  MarKetUp
//
//  Created by Sam Ding on 9/16/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import Foundation

class User {
    var userId: String
    var cashes: Float
    var values: Float
    var ownedStocks: [Stock]
    var ownedStocksShares: [Stock:Int]
    var watchList: [Stock]
    
    
    static let shared = User(userId: "testID", cashes: 10000, values: 0, ownedStocks: [], watchList: [], ownedStocksShares: [:])

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
    func setOwnedStock(stock: Stock){
        for i in 0..<self.ownedStocks.count{
            if ownedStocks[i] == stock {
                ownedStocks[i] = stock
            }
        }
    }
       
    //fetch data to current watchlist
    func setWatchList(stock: Stock){
        for i in 0..<self.watchList.count{
            if watchList[i] == stock {
                watchList[i] = stock
            }
        }

    }
    
    // Adding shares to a specific stock
    func addShareToStock(stock: Stock, numOfShares: Int){
        if !ownedStocks.contains(stock) {
            self.ownedStocks.append(stock)
            self.ownedStocksShares[stock] = 0
        }
        self.ownedStocksShares[stock]! += numOfShares
        let totalCost = stock.price * Float(numOfShares)
        self.cashes -= totalCost
        self.values += totalCost
        
    }
    
    // Selling number of shares from a specific stock
    func sellShareFromStock(stock: Stock, numOfShares: Int){
        self.ownedStocksShares[stock]! -= numOfShares
        let totalValue = stock.price * Float(numOfShares)
        self.cashes += totalValue
        self.values -= totalValue
        
        if self.ownedStocksShares[stock] == 0, let index = self.ownedStocks.firstIndex(of: stock){
            self.ownedStocks.remove(at: index)
            self.ownedStocksShares.removeValue(forKey: stock)
        }
    }
    
    func addStocks(stock: Stock, type: String, index: Int){
        if !self.watchList.contains(stock) || !self.ownedStocks.contains(stock) {
            if type == "watchList" {
                // watchlist
                self.watchList.insert(stock, at: index)
            } else {
                //ownedStock
                self.ownedStocks.append(stock)
            }
        }
    }
    
    func cancelFollowingStock(stock: Stock){
        if self.watchList.contains(stock){
            if let index = self.watchList.firstIndex(of: stock) {
                watchList.remove(at: index)
            }
        } else {
            // Error Catching
            print("There is no such stock stored in WatchList")
        }
    }
    
    
    
}

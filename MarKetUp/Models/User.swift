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
            self.ownedStocksShares[stock]! += numOfShares
        } else {
            self.ownedStocksShares[stock]! += numOfShares
        }
        
    }
    
    // Selling number of shares from a specific stock
    func sellShareFromStock(stock: Stock, numberOfShares: Int){
        self.ownedStocksShares[stock]! -= numberOfShares
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
        }
    }
    
    
    
    
    
}

//
//  Stocks.swift
//  MarKetUp
//
//  Created by Sam Ding on 9/3/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import Foundation


struct Stock{

    var symbol: String            // "AAPL"
    var price: Float              // 210.98
    var name: String              // "Apple Inc."
    var change_pct: String        // "-0.81"
    var day_change: String        // “-1.81”
    var volumn: Int            // “20234415”
    
    init(symbol: String, price: Float, change_pct: String, name: String?, day_change: String?, volumn: Int?){
        self.symbol = symbol
        self.price = price
        self.change_pct = change_pct
        self.name = name ?? ""
        self.day_change = day_change ?? ""
        self.volumn = volumn ?? -1
    }
    
    init(_ dictionary: [String: Any]) {
        self.symbol = dictionary["symbol"] as? String ?? ""
        let priceStr = dictionary["price"] as? String ?? ""
        self.price = (Float(priceStr))!
        self.change_pct = dictionary["change_pct"] as? String ?? ""
        self.change_pct += "%"
        self.name = dictionary["name"] as? String ?? ""
        self.day_change = dictionary["day_change"] as? String ?? ""
        let volumnStr = dictionary["volumn"] as? String ?? ""
        self.volumn = Int(volumnStr)!
    }
    
}

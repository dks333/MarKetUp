//
//  Stocks.swift
//  MarKetUp
//
//  Created by Sam Ding on 9/3/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import Foundation


struct Stock: Hashable{

    var symbol: String            // "AAPL"
    var price: Float              // 210.98
    var name: String              // "Apple Inc."
    var change_pct: String        // "-0.81"
    var day_change: String        // “-1.81”
    var volumn: Int            // “20234415”
    var close_yesterday: Float  // "221.03"
    
    
    
    init(symbol: String? = nil, price: Float? = nil, change_pct: String? = nil, name: String? = nil, day_change: String? = nil, volumn: Int? = nil, close_yesterday: Float? = nil){
        self.symbol = symbol ?? ""
        self.price = price ?? 0.0
        self.change_pct = change_pct ?? "0.0%"
        self.name = name ?? ""
        self.day_change = day_change ?? "0.0"
        self.volumn = volumn ?? 0
        self.close_yesterday = close_yesterday ?? 0.0
    }
    
    init(_ dictionary: [String: Any]) {
        self.symbol = dictionary["symbol"] as? String ?? ""
        let priceStr = dictionary["price"] as? String ?? ""
        self.price = Float(priceStr) ?? 0.0
        self.change_pct = dictionary["change_pct"] as? String ?? "0.0"
        self.change_pct += "%"
        self.name = dictionary["name"] as? String ?? ""
        self.day_change = dictionary["day_change"] as? String ?? "0.0"
        let volumnStr = dictionary["volumn"] as? String ?? ""
        self.volumn = (Int(volumnStr) ?? 0)
        let close_yesterdayStr = dictionary["close_yesterday"] as? String ?? "0.0"
        self.close_yesterday = Float(close_yesterdayStr) ?? 0.0
        
        
        if day_change.contains("N/A") || change_pct.contains("N/A"){
            day_change = "0.0"
            change_pct = "0.0%"
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(symbol.hashValue)
    }
    
    static func == (lhs: Stock, rhs: Stock) -> Bool {
        return lhs.symbol == rhs.symbol
    }
    
    
}

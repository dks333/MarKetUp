//
//  Stocks.swift
//  MarKetUp
//
//  Created by Sam Ding on 9/3/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import Foundation


struct Stocks{
    var quote: String
    var currentPrice: Float
    var percentage: String
    
    init(quote: String, currentPrice: Float, percentage: String){
        self.quote = quote
        self.currentPrice = currentPrice
        self.percentage = percentage
    }
    
}

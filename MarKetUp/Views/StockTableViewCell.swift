//
//  TableViewCell.swift
//  MarKetUp
//
//  Created by Sam Ding on 9/3/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import UIKit
import AudioToolbox

 var switchBtnPressed = false // when false, displaying percentage

class StockTableViewCell: UITableViewCell {
    
    @IBOutlet weak var quoteLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var switchBtn: UIButton!
    @IBOutlet weak var numOfShareLbl: UILabel!
    
    var quote: String!
    var price: Float!
    var percentage: String!
    var dayChange: String!
    var numOfShare: String!
    
    
    func setup(quote: String, price: Float?, percentage: String?, dayChange: String?){
        quoteLbl.text = quote
        priceLbl.text = String(price!)
        if dayChange?.first == "-"{
            switchBtn.setTitleWithOutAnimation(title: switchBtnPressed ? dayChange! : percentage!)
        } else {
            switchBtn.setTitleWithOutAnimation(title: switchBtnPressed ? "+" + dayChange! : percentage!)
        }
        
        self.quote = quote
        self.price = price
        self.percentage = percentage
        self.dayChange = (dayChange!.first == "-") ? "\(dayChange!)" : "+\(dayChange!)"
        
        if price != 0.0 {
            self.isUserInteractionEnabled = true
            if percentage?.first == "-" {
                priceLbl.textColor = .customRed
                switchBtn.backgroundColor = .customRed
            } else {
                priceLbl.textColor = .custumGreen
                switchBtn.backgroundColor = .custumGreen
            }
        } else {
            // If the Network is not working, block the user interaction
            priceLbl.textColor = .darkGray
            switchBtn.backgroundColor = .darkGray
            self.isUserInteractionEnabled = false
        }
    }
    
    func setUpNumOfShares(numOfShare: String?){
        numOfShareLbl.text = numOfShare
        self.numOfShare = numOfShare
    }
    
    private func setupView(){
        self.selectionStyle = .none
        self.switchBtn.layer.cornerRadius = 5
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

}


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
    
    var quote: String!
    var price: Float!
    var percentage: String!
    var dayChange: String!
    
    
    func setup(quote: String, price: Float?, percentage: String?, dayChange: String?){
        quoteLbl.text = quote
        priceLbl.text = String(price!)
        switchBtn.setTitleWithOutAnimation(title: switchBtnPressed ? dayChange : percentage)
        
        self.quote = quote
        self.price = price
        self.percentage = percentage
        self.dayChange = (dayChange!.first == "-") ? "\(dayChange!)" : "+\(dayChange!)"
        
        
        if percentage?.first == "-" {
            priceLbl.textColor = .customRed
            switchBtn.backgroundColor = .customRed
        } else {
            priceLbl.textColor = .custumGreen
            switchBtn.backgroundColor = .custumGreen
        }
    }
    
    private func setupView(){
        self.selectionStyle = .none
        self.switchBtn.layer.cornerRadius = 5
        
    }
    
    @IBAction @objc func switchDayChangeAndPercentage(_ sender: Any) {
        switchStates(switchBtn: sender as! UIButton)
    }
    
    func switchStates(switchBtn: UIButton){
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if switchBtn.currentTitle == percentage {
            switchBtn.setTitleWithOutAnimation(title: dayChange)
            switchBtnPressed = true
        } else {
            switchBtn.setTitleWithOutAnimation(title: percentage)
            switchBtnPressed = false
        }
        //switchBtn.setTitleWithOutAnimation(title: (switchBtn.titleLabel?.text == percentage) ? dayChange : percentage)
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


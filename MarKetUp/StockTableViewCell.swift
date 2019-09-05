//
//  TableViewCell.swift
//  MarKetUp
//
//  Created by Sam Ding on 9/3/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import UIKit

class StockTableViewCell: UITableViewCell {

    @IBOutlet weak var quoteLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var percentageLbl: UILabel!
    
    func setup(quote: String, price: Float, percentage: String){
        quoteLbl.text = quote
        priceLbl.text = String(price)
        percentageLbl.text = percentage
        
        if percentage.first == "-" {
            priceLbl.backgroundColor = .red
            percentageLbl.textColor = .red
        } else {
            priceLbl.backgroundColor = .green
            percentageLbl.textColor = .green
        }
    }
    
    private func setupView(){
        self.selectionStyle = .none
        self.priceLbl.layer.cornerRadius = 5
        
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

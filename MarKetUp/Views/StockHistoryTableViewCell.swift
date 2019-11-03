//
//  StockHistoryTableViewCell.swift
//  MarKetUp
//
//  Created by Sam Ding on 11/2/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import UIKit

class StockHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var symbolLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

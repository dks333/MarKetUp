//
//  searchResultTableViewCell.swift
//  MarKetUp
//
//  Created by Sam Ding on 10/2/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import UIKit

class searchResultTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var symbolLbl: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.backgroundColor = .GrayBlack
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // Configure the view for the selected state
    }
    
    

}

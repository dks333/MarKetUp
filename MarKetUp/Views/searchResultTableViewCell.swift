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
        self.addBtn.layer.borderWidth = 1
        addBtn.layer.cornerRadius = self.frame.height * 0.15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // Configure the view for the selected state
    }
    
    

}

//
//  ProfileSelectionTwoTableViewCell.swift
//  MarKetUp
//
//  Created by Sam Ding on 11/1/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import UIKit

class ProfileSelectionTwoTableViewCell: UITableViewCell {

    @IBOutlet weak var backgroundContentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpView()
    }
    
    private func setUpView(){
        backgroundContentView.layer.cornerRadius = 8
        self.selectedBackgroundView = UIView()
         backgroundContentView.addDropShadow(scale: true, cornerRadius: 8)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

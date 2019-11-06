//
//  ProfileSelectionTableViewCell.swift
//  MarKetUp
//
//  Created by Sam Ding on 10/31/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import UIKit

class ProfileSelectionOneTableViewCell: UITableViewCell {
    
    @IBOutlet var backgroundContentView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpView()
        self.selectedBackgroundView = UIView()
    }
    
    private func setUpView(){
        backgroundContentView.layer.cornerRadius = 25
        self.selectedBackgroundView = UIView()
        backgroundContentView.layer.borderColor = UIColor.lightGreen.cgColor
        backgroundContentView.layer.borderWidth = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

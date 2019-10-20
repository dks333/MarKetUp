//
//  PurchaseTableViewCell.swift
//  MarKetUp
//
//  Created by Sam Ding on 10/8/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import UIKit

class PurchaseCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var purchaseBtn: UIButton!
    @IBOutlet weak var itemLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }
    
    private func setupView(){
        // UI
        purchaseBtn.layer.borderWidth = 1
        purchaseBtn.layer.borderColor = UIColor.lightGreen.cgColor
        purchaseBtn.layer.cornerRadius = 8
    }

}

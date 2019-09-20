//
//  IndividualStockViewController.swift
//  MarKetUp
//
//  Created by Sam Ding on 9/16/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import UIKit
import Foundation

class IndividualStockViewController: UIViewController {

    @IBOutlet weak var stockNameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var percentageLbl: UILabel!
    
    var stockName = ""
    var stockPrice = Float(0.0)
    var stockPercentage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.setTabBarVisible(visible: false, animated: true)
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.setTabBarVisible(visible: true, animated: true)
        super.viewWillDisappear(animated)
    }
    
    private func setupView(){
        // Make navigation bar transparent
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.topItem?.title = ""
        
        stockNameLbl.text = stockName
        priceLbl.text = String("\(stockPrice)")
        percentageLbl.text = stockPercentage
        
        if percentageLbl.text?.first == "-" {
            priceLbl.textColor = .red
            percentageLbl.textColor = .red
        } else {
            priceLbl.textColor = .green
            percentageLbl.textColor = .green
        }
        
    }

    


}

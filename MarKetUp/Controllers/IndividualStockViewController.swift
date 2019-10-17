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
    
    var currentStock = Stock()
    var user = User(userId: "test", cashes: 10000.0, values: 0.0, ownedStocks: [Stock(symbol: "AAPL"),Stock(symbol: "MSFT")], watchList: [], ownedStocksShares: [:])

    @IBOutlet weak var stockNameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var percentageLbl: UILabel!
    @IBOutlet weak var companyNameLbl: UILabel!
    
    @IBOutlet weak var sellStockBtn: UIButton!{
        didSet{
            if !user.isHeldStock(stock: currentStock) {
                sellStockBtn.isEnabled = false
                sellStockBtn.backgroundColor = .gray
            }
        }
    }
    @IBOutlet weak var buyStockBtn: UIButton!
    
    
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
        navigationController?.navigationBar.tintColor = .custumGreen
        
        //UI
        sellStockBtn.layer.cornerRadius = 5
        buyStockBtn.layer.cornerRadius = 5

        stockNameLbl.text = currentStock.symbol
        priceLbl.text = String("\(currentStock.price)")
        percentageLbl.text = currentStock.change_pct
        companyNameLbl.text = currentStock.name
        
        if percentageLbl.text?.first == "-" {
            priceLbl.textColor = .customRed
            percentageLbl.textColor = .customRed
        } else {
            priceLbl.textColor = .custumGreen
            percentageLbl.textColor = .custumGreen
        }
        
        
        
    }
    
    
    
    @IBAction func sellingStock(_ sender: Any) {
        sellStockBtn.isEnabled = true
        sellStockBtn.backgroundColor = .lightGreen
        
    }
    
    @IBAction func buyingStock(_ sender: Any) {
        
    }
    
    


}

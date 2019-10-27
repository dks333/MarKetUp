//
//  TradingViewController.swift
//  MarKetUp
//
//  Created by Sam Ding on 10/17/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import UIKit

class TradingViewController: UIViewController {

    @IBOutlet weak var vcTitleLbl: UILabel!
    @IBOutlet weak var resultLbl: UILabel!
    @IBOutlet weak var availableValuesLbl: UILabel!
    @IBOutlet weak var tradingBtn: UIButton!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var totalCostValueLbl: UILabel!
    @IBOutlet var stackViews: UIStackView!
    
    private var inputTrackerStr = ""
    private var hasClickedAnOperand = false
    var selling = false   // sell = false  && buy = true
    
    var currentStock = Stock()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func dismissTradingVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupView(){
        // Set up trading button
        tradingBtn.layer.cornerRadius = 13
        tradingBtn.alpha = 0
        
        if !selling {
            // Sell
            vcTitleLbl.text = "Sell"
            tradingBtn.setTitle("Sell", for: .normal)
            
            availableValuesLbl.text = "\(User.shared.ownedStocksShares[currentStock]!) shares"
        } else {
            // Buy
            vcTitleLbl.text = "Buy"
            tradingBtn.setTitle("Buy", for: .normal)
            availableValuesLbl.text = "$\(User.shared.cashes) available"
        }
        
        // Market Price set up
        priceLbl.text = "$\(currentStock.price)"
        
        // UI for stackView
        stackViews.addBottomBorder(with: .black, andWidth: 1.3)
    }
    
    
    @IBAction func tradingAction(_ sender: Any) {
        if !selling {
            // sell
            
        } else {
            // buy
            User.shared.addShareToStock(stock: currentStock, numOfShares: Int(inputTrackerStr)!)
        }
        dismiss(animated: true)
    }
    
    @IBAction func performNumTracking(_ button: UIButton) {
        hasClickedAnOperand = true
        resultLbl.textColor = .white
        totalCostValueLbl.textColor = .white
        let digit = button.titleLabel?.text ?? ""
        performInputTracking(digit)
        
    }
    
    @IBAction func backspace(_ sender: Any) {
        hasClickedAnOperand = false
        performInputTracking("")
    }
    
    // tracking numbers
    private func performInputTracking(_ digit: String) {
        if hasClickedAnOperand {
            //Typing numbers
            if inputTrackerStr.count < 15 {
                inputTrackerStr += digit
                resultLbl.text = "\(inputTrackerStr)"
            }
        } else {
            inputTrackerStr = String(inputTrackerStr.dropLast())
            resultLbl.text = "\(inputTrackerStr)"
            if inputTrackerStr == "" {
                // when there is no number entered
                resultLbl.textColor = .lightGray
                resultLbl.text = "0"
                totalCostValueLbl.textColor = .darkGray
                totalCostValueLbl.text = "0"
            }
        }
        
        let numOfShares = Float(resultLbl.text!)
        totalCostValueLbl.text = "\(numOfShares! * currentStock.price)"
        
        
        
        UIView.animate(withDuration: (self.inputTrackerStr == "") ? 0.2 : 0.3, animations: {
            self.tradingBtn.alpha = (self.inputTrackerStr != "") ? 1.0 : 0.0
        })
    }
    

}

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
    
    private var inputTrackerStr = ""
    private var hasClickedAnOperand = false
    var selling = false   // sell = false  && buy = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setupView(){
        // Set up trading button
        tradingBtn.layer.cornerRadius = 10
        tradingBtn.alpha = 0
        
        if !selling {
            // Sell
            vcTitleLbl.text = "Sell"
            tradingBtn.setTitle("Sell", for: .normal)
            
        } else {
            // Buy
            vcTitleLbl.text = "Buy"
            tradingBtn.setTitle("Buy", for: .normal)
        }
    }
    
    @IBAction func performNumTracking(_ button: UIButton) {
        hasClickedAnOperand = true
        resultLbl.textColor = .white
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
            if inputTrackerStr.count < 15 {
                inputTrackerStr += digit
                resultLbl.text = "\(inputTrackerStr)"
            }
        } else {
            inputTrackerStr = String(inputTrackerStr.dropLast())
            resultLbl.text = "\(inputTrackerStr)"
            if inputTrackerStr == "" {
                resultLbl.textColor = .lightGray
                resultLbl.text = "0"
            }
        }
        
        UIView.animate(withDuration: (self.inputTrackerStr == "") ? 0.2 : 0.3, animations: {
            self.tradingBtn.alpha = (self.inputTrackerStr != "") ? 1.0 : 0.0
        })
    }
    

}

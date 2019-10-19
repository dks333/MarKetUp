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
        if !selling {
            vcTitleLbl.text = "Sell"
        } else {
            vcTitleLbl.text = "Buy"
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
    
    private func performInputTracking(_ digit: String) {
        if hasClickedAnOperand {
            inputTrackerStr += digit
            resultLbl.text = "\(inputTrackerStr)"
        } else {
            inputTrackerStr = String(inputTrackerStr.dropLast())
            resultLbl.text = "\(inputTrackerStr)"
            if inputTrackerStr == "" {
                resultLbl.textColor = .lightGray
                resultLbl.text = "0"
            }
        }
    }
    

}

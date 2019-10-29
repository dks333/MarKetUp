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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
        if #available(iOS 13.0, *) {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        } else {
            // Fallback on earlier versions
        }
        

        let inputNumOfShares = Int(inputTrackerStr)!
        if !selling {
            // sell
            if User.shared.ownedStocksShares[currentStock]! >=  inputNumOfShares{
                // Check if user has this number of current stock
                User.shared.sellShareFromStock(stock: currentStock, numOfShares: inputNumOfShares)
                dismiss(animated: true)
            } else {
                let SellingLimitAlert = UIAlertController(title: "Insufficient Shares", message: nil, preferredStyle: .alert)
                SellingLimitAlert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
                SellingLimitAlert.message = "The max number of \(currentStock.symbol) stock you are able to sell is \(User.shared.ownedStocksShares[currentStock]!)"
                self.present(SellingLimitAlert, animated: true, completion: nil)
            }
        } else {
            // buy
            let totalCost = Float(inputTrackerStr)! * currentStock.price
            if User.shared.cashes >= totalCost{
                // Check if user has such cashes
               User.shared.addShareToStock(stock: currentStock, numOfShares: inputNumOfShares)
                dismiss(animated: true)
            } else {
               let BuyingLimitAlert = UIAlertController(title: "Insufficient Cashes", message: nil, preferredStyle: .alert)
                BuyingLimitAlert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
                BuyingLimitAlert.message = "Your available cashes are $\(User.shared.cashes)"
               self.present(BuyingLimitAlert, animated: true, completion: nil)
            }
        }
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

//
//  TradingViewController.swift
//  MarKetUp
//
//  Created by Sam Ding on 10/17/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import UIKit
import CoreData

class TradingViewController: UIViewController {

    @IBOutlet weak var vcTitleLbl: UILabel!
    @IBOutlet weak var resultLbl: UILabel!
    @IBOutlet weak var availableValuesLbl: UILabel!
    @IBOutlet weak var tradingBtn: UIButton!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var totalCostValueLbl: UILabel!
    @IBOutlet var stackViews: UIStackView!
    @IBOutlet weak var backspaceBtn: UIButton!
    
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
        
        // UI
        stackViews.addBottomBorder(with: .black, andWidth: 1.3)
        //backspaceBtn.imageEdgeInsets = UIEdgeInsets(top: 10, left: 5, bottom: 5, right: 5)
    }
    
    
    @IBAction func tradingAction(_ sender: Any) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        

        let inputNumOfShares = Int(inputTrackerStr)!
        
        if inputNumOfShares == 0 {
            let ZeroLimitAlert = UIAlertController(title: "Zero Share", message: nil, preferredStyle: .alert)
                ZeroLimitAlert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
                ZeroLimitAlert.message = "Number of Shares cannot be 0"
                self.present(ZeroLimitAlert, animated: true, completion: nil)
        } else {
        
            if !selling {
                // sell
                if User.shared.ownedStocksShares[currentStock]! >=  inputNumOfShares{
                    // Check if user has this number of current stock
                    User.shared.sellShareFromStock(stock: currentStock, numOfShares: inputNumOfShares)
                    
                    // Delete shares in DB
                    
                    let managedContext = PersistenceServce.context
                    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "StoredStock")
                    fetchRequest.predicate = NSPredicate(format: "symbol == %@" ,currentStock.symbol)

                   do {
                        let results = try managedContext.fetch(fetchRequest)
                        if User.shared.ownedStocks.contains(currentStock) {
                            let shares = User.shared.ownedStocksShares[currentStock]
                            if results.count != 0 {
                                let stock = results[0]
                                stock.setValue(shares, forKey: "shares")
                            }
                        } else {
                            for object in results {
                                managedContext.delete(object)
                            }
                        }
                    
                    // Stock Purchased History Storing
                     let stockHistory = StockHistory(context: PersistenceServce.context)
                     stockHistory.symbol = currentStock.symbol
                     stockHistory.type = "Sell"
                     stockHistory.price = currentStock.price
                     stockHistory.shares = Int32(inputNumOfShares)
                    
                        let date = Date()
                        let calendar = NSCalendar.current
                        let hour = calendar.component(.hour, from: date)
                        let minutes = calendar.component(.minute, from: date)
                        let day = calendar.component(.day, from: date)
                        let month = calendar.component(.month, from: date)
                        let year = calendar.component(.year, from: date)
                        let dateStr = "\(month)/\(day)/\(year)"
                        let timeStr = "\(hour):\(minutes)"

                    stockHistory.date = dateStr
                    stockHistory.time = timeStr
                    
                        UserDefaults.standard.setValue(User.shared.cashes, forKey: "cash")
                        PersistenceServce.saveContext()
                    
                       
                       
                   }catch let error as NSError {
                       print("Could not fetch. \(error), \(error.userInfo)")
                       
                   }
                    
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

                    
                    let managedContext = PersistenceServce.context
                    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "StoredStock")
                     fetchRequest.predicate = NSPredicate(format: "symbol == %@" ,currentStock.symbol)

                    do {
                         let results = try managedContext.fetch(fetchRequest)
                         if results.count != 0{
                             let shares = User.shared.ownedStocksShares[currentStock]   // Updated
                             let stock = results[0]
                            let previousBuyingPrice = stock.value(forKey: "buyingPrice") as! Float
                            
                            // Calculating the
                            let previousTotalValues = previousBuyingPrice * Float(User.shared.ownedStocksShares[currentStock]! - inputNumOfShares)
                            let adjustedBuyingPriceAverage: Float = (previousTotalValues + currentStock.price * Float(inputNumOfShares)) / Float(User.shared.ownedStocksShares[currentStock]!)
                            
                            
                             
                             stock.setValue(Int32(shares!), forKey: "shares")
                            stock.setValue(adjustedBuyingPriceAverage, forKey: "buyingPrice")
                             
                         } else {
                             let stockWithSymbolOnly = StoredStock(context: PersistenceServce.context)
                             stockWithSymbolOnly.symbol = currentStock.symbol
                             stockWithSymbolOnly.buyingPrice = currentStock.price
                             stockWithSymbolOnly.shares = Int32(inputNumOfShares)
                         }
                        
                        // Stock Purchased History Storing
                         let stockHistory = StockHistory(context: PersistenceServce.context)
                         stockHistory.symbol = currentStock.symbol
                         stockHistory.type = "Buy"
                         stockHistory.price = currentStock.price
                         stockHistory.shares = Int32(inputNumOfShares)
                        
                            let date = Date()
                            let calendar = NSCalendar.current
                            let hour = calendar.component(.hour, from: date)
                            let minutes = calendar.component(.minute, from: date)
                            let day = calendar.component(.day, from: date)
                            let month = calendar.component(.month, from: date)
                            let year = calendar.component(.year, from: date)
                            let dateStr = "\(month)/\(day)/\(year)"
                            let timeStr = "\(hour):\(minutes)"

                        stockHistory.date = dateStr
                        stockHistory.time = timeStr
                        
                         UserDefaults.standard.setValue(User.shared.cashes, forKey: "cash")
                         PersistenceServce.saveContext()
                     
                        
                        
                    }catch let error as NSError {
                        print("Could not fetch. \(error), \(error.userInfo)")
                        
                    }
                    
                    
                    dismiss(animated: true)
                
                    
                } else {
                   let BuyingLimitAlert = UIAlertController(title: "Insufficient Cashes", message: nil, preferredStyle: .alert)
                    BuyingLimitAlert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
                    BuyingLimitAlert.message = "Your available cashes are $\(User.shared.cashes)"
                   self.present(BuyingLimitAlert, animated: true, completion: nil)
                }
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

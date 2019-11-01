//
//  IndividualStockViewController.swift
//  MarKetUp
//
//  Created by Sam Ding on 9/16/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import UIKit
import Foundation
import SwiftChart
import CoreData

class IndividualStockViewController: UIViewController {
    
    var currentStock = Stock()
    
    var seriesData: [Double] = []
    var labels: [Double] = []
    var labelsAsString: Array<String> = []
    
    //Constraints
    @IBOutlet weak var labelLeadingMarginConstraint: NSLayoutConstraint!
    fileprivate var labelLeadingMarginInitialConstant: CGFloat!
    @IBOutlet weak var chartWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var stockNameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var percentageLbl: UILabel!
    @IBOutlet weak var companyNameLbl: UILabel!
    @IBOutlet weak var cancelFollowingBtn: UIButton!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var chart: Chart!
    
    @IBOutlet weak var sellStockBtn: UIButton!{
        didSet{
            if !User.shared.isHeldStock(stock: currentStock){
                sellStockBtn.isEnabled = false
                sellStockBtn.backgroundColor = .gray
            }
        }
    }
    @IBOutlet weak var buyStockBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        initializeChart()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
       // self.setTabBarVisible(visible: false, animated: true)
        //self.tabBarController?.tabBar.isHidden = true
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        //self.setTabBarVisible(visible: true, animated: true)
        //self.tabBarController?.tabBar.isHidden = false
        super.viewWillDisappear(animated)
    }
    
    fileprivate func setupView(){
        
        
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
        
        checkIncOrDec()
        
        cancelFollowingBtn.tintColor = (User.shared.watchList.contains(currentStock)) ? .darkGray : .custumGreen
        
        // CancelFollowingBtn should not present in ownedStock VC
//        if User.shared.isHeldStock(stock: currentStock) && !User.shared.watchList.contains(currentStock){
//            cancelFollowingBtn.isHidden = true
//        }
        
        // Chart
        chart.delegate = self
        chart.hideHighlightLineOnTouchEnd = true
        
        labelLeadingMarginInitialConstant = labelLeadingMarginConstraint.constant
        setUpTimeLbl()
        
        // Before data finish loading
        self.showSpinner(onView: self.chart)
        self.chart.isUserInteractionEnabled = false
    }
    
    fileprivate func setUpTimeLbl(){
        timeLbl.text = "00:00"
        timeLbl.textColor = .black
        
    }
    @IBAction func sellingStocks(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TradingViewController {
            vc.currentStock = currentStock
            if segue.identifier == "SellingSegue" {
                vc.selling = false
            } else {
                vc.selling = true
            }
        } else {
            print("Error when seguing from IndividualStockVC to TradingVC")
        }
    }
    
    
    private var index = 0
    
    @IBAction func cancelFollowing(_ sender: Any) {
        if !User.shared.watchList.contains(currentStock) && User.shared.isHeldStock(stock: currentStock){
            // Storing
            cancelFollowingBtn.tintColor = .darkGray
            User.shared.addStocks(stock: currentStock, type: "watchList", index: index)
            
            // Add to database
            if !currentStock.checkIfItemExist(symbol: currentStock.symbol){
               let stockWithSymbolOnly = WatchList(context: PersistenceServce.context)
               stockWithSymbolOnly.symbol = currentStock.symbol
               PersistenceServce.saveContext()
            }
            
        } else {
            // Deleting
            index = User.shared.watchList.firstIndex(of: self.currentStock)!
            User.shared.cancelFollowingStock(stock: currentStock)
            cancelFollowingBtn.tintColor = .custumGreen
            
            // Delete from Core Data
            let managedContext = PersistenceServce.context
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WatchList")
            fetchRequest.predicate = NSPredicate(format: "symbol == %@" ,currentStock.symbol)
            do {
                let objects = try managedContext.fetch(fetchRequest)
                for object in objects {
                    managedContext.delete(object)
                }
                try managedContext.save()
            } catch _ {
                // error handling
                print("Cannot Delete \(currentStock.symbol)")
            }
        }
        
        
    }
    

}

extension IndividualStockViewController: ChartDelegate{
    

    
    
    func initializeChart() {
        
        let symbolStr = currentStock.symbol
        
        guard let url = URL(string: "https://intraday.worldtradingdata.com/api/v1/intraday?symbol=\(symbolStr)&range=1&interval=5&sort=asc&api_token=\(WorldTradingDataAPIKey)") else {return}

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
           guard let dataResponse = data,
               error == nil else {
                   print(error?.localizedDescription ?? "Response Error")
                   return }
           do{
               //here dataResponse received from a network request
            let jsonResponse = try JSONSerialization.jsonObject(with:
                   dataResponse, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
            guard let dataArray = jsonResponse["intraday"] as? Dictionary<String, AnyObject> else { return }
            let sortedDataArray = dataArray.sorted(by: {$0.key < $1.key})
            
            var enumeratedNum = 0
            
            for (key, value) in sortedDataArray{
                self.seriesData.append(Double(Float(value["close"] as? String ?? "") ?? 0.0))
                self.labels.append(Double(enumeratedNum))
                
                let start = key.index(key.startIndex, offsetBy: 11)
                let end = key.index(key.endIndex, offsetBy: -3)
                let range = start..<end

                let mySubstring = key[range]  // play
                self.labelsAsString.append(String(mySubstring))
                enumeratedNum += 1
            }
            

            DispatchQueue.main.async {
                // After load up data
                self.removeSpinner()
                self.chart.isUserInteractionEnabled = true
                
                let series = ChartSeries(self.seriesData)
                series.area = true
               
                // Configure chart layout
                self.chart.lineWidth = 1
                self.chart.areaAlphaComponent = 0.07
                
                self.chart.showYLabelsAndGrid = false
                self.chart.showXLabelsAndGrid = false
                
                
                // TODO: Some stocks may have different number of <labelAsString>
                // 拿一个现实的时间，然后divide by 5， if 时间 == key, get(value), else : get(lastValue)
                self.chartWidthConstraint = self.chartWidthConstraint.setMultiplier(1 / 78 * CGFloat(self.labelsAsString.count))
                
                self.chart.gridColor = .white
                self.chart.maxY = self.seriesData.max()! * 1.001
                self.chart.minY = self.seriesData.min()! * 0.999
                self.chart.labelColor = .white
                self.chart.highlightLineColor = .white
                series.colors = (
                    above: .lightGreen,
                    below: .red,
                  zeroLevel: Double(self.currentStock.close_yesterday)
                )
                
                self.chart.add(series)
                self.chart.setNeedsDisplay()
                self.chart.layoutIfNeeded()
            }
              
           } catch let parsingError {
               print("Error", parsingError)
           }
        }
        task.resume()
           
        
           
    }
    
    func didTouchChart(_ chart: Chart, indexes: [Int?], x: Double, left: CGFloat) {
        
        if let value = chart.valueForSeries(0, atIndex: indexes[0]) {
            
            let numberFormatter = NumberFormatter()
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 2
            priceLbl.text = numberFormatter.string(from: NSNumber(value: value))
            var percentage = (value/Double(currentStock.close_yesterday) - 1.0) * 100.0
            
            
            
            
            // Show percentage
            if percentage < 0.0 {
                // Negative
                percentage *= -1.0
                percentageLbl.text = "-\(numberFormatter.string(from: NSNumber(value: percentage)) ?? "0.0")%"
                percentageLbl.textColor = .customRed
                
            } else {
                // Positive
                percentageLbl.text = "\(numberFormatter.string(from: NSNumber(value: percentage)) ?? "0.0")%"
                percentageLbl.textColor = .custumGreen
            }

            // Only presenting the time, NOT DATE
            timeLbl.textColor = .lightGray
            timeLbl.text = labelsAsString[Int(x.rounded())]
            
            // Align the label to the touch left position, centered
            var constant = labelLeadingMarginInitialConstant + left - timeLbl.frame.width/2

            // Avoid placing the label on the left of the chart
            if constant < labelLeadingMarginInitialConstant {
                constant = labelLeadingMarginInitialConstant
            }
            
            // Avoid placing the label on the right of the chart
            let rightMargin = chart.frame.width - timeLbl.frame.width
            if constant > rightMargin {
                constant = rightMargin
            }

            labelLeadingMarginConstraint.constant = constant
        }
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        priceLbl.text = "\(currentStock.price)"
        percentageLbl.text = "\(currentStock.change_pct)"
        checkIncOrDec()
        setUpTimeLbl()
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        priceLbl.text = "\(currentStock.price)"
        percentageLbl.text = "\(currentStock.change_pct)"
        checkIncOrDec()
        setUpTimeLbl()
        
    }
    
    // Change UI for percentageLBL
    func checkIncOrDec(){
        if currentStock.change_pct.first == "-" {
           //priceLbl.textColor = .customRed
           percentageLbl.textColor = .customRed
        } else {
           //priceLbl.textColor = .custumGreen
           percentageLbl.textColor = .custumGreen
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        // Redraw chart on rotation
        chart.setNeedsDisplay()
        
    }
    
    
}

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

class IndividualStockViewController: UIViewController {
    
    var currentStock = Stock()

    @IBOutlet weak var stockNameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var percentageLbl: UILabel!
    @IBOutlet weak var companyNameLbl: UILabel!
    @IBOutlet weak var cancelFollowingBtn: UIButton!
    @IBOutlet weak var chart: Chart!
    
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
        initializeChart()
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
        
        cancelFollowingBtn.tintColor = .darkGray
        
        // CancelFollowingBtn should not present in ownedStock VC
        if user.isHeldStock(stock: currentStock) {
            cancelFollowingBtn.isHidden = true
        }
        
        // Chart
        chart.delegate = self
        chart.hideHighlightLineOnTouchEnd = true
        
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
    
    
    var index = 0
    
    @IBAction func cancelFollowing(_ sender: Any) {
        if user.watchList.contains(currentStock) {
            index = user.watchList.firstIndex(of: self.currentStock)!
            user.cancelFollowingStock(stock: currentStock)
            cancelFollowingBtn.tintColor = .custumGreen
        } else {
            cancelFollowingBtn.tintColor = .darkGray
            user.addStocks(stock: currentStock, type: "watchList", index: index)
        }
        
        
    }
    

}

extension IndividualStockViewController: ChartDelegate{
    

    
    
    
    func initializeChart() {
        
        let symbolStr = currentStock.symbol
        
        var seriesData: [Double] = []
        var labels: [Double] = []
        var labelsAsString: Array<String> = []
        
        let url = URL(string: "https://intraday.worldtradingdata.com/api/v1/intraday?symbol=\(symbolStr)&range=1&interval=5&sort=asc&api_token=\(WorldTradingDataAPIKey)")

        let task = URLSession.shared.dataTask(with: (url)!) { (data, response, error) in
           guard let dataResponse = data,
               error == nil else {
                   print(error?.localizedDescription ?? "Response Error")
                   return }
           do{
               //here dataResponse received from a network request
            let jsonResponse = try JSONSerialization.jsonObject(with:
                   dataResponse, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
            guard let dataArray = jsonResponse["intraday"] as? Dictionary<String, AnyObject> else { return }
            
            var enumeratedNum = 0
            
            for (key, value) in dataArray{
                seriesData.append(Double(Float(value["close"] as? String ?? "") ?? 0.0))
                labels.append(Double(enumeratedNum))
                labelsAsString.append(key)
                enumeratedNum += 1
            }

            DispatchQueue.main.async {
                let series = ChartSeries(seriesData)
                series.area = false

                // Configure chart layout

                self.chart.lineWidth = 1
//                self.chart.labelFont = UIFont.systemFont(ofSize: 12)
//                self.chart.xLabels = labels
//                self.chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Double) -> String in
//                   return labelsAsString[labelIndex]
//                }
//                self.chart.xLabelsTextAlignment = .center
                self.chart.showYLabelsAndGrid = false
                self.chart.showXLabelsAndGrid = false
                if self.currentStock.change_pct.starts(with: "-"){
                    series.color = .customRed
                } else {
                    series.color = .custumGreen
                }
                self.chart.gridColor = .clear

                self.chart.labelColor = .white
                self.chart.highlightLineColor = .white
                
                self.chart.add(series)
                self.chart.setNeedsDisplay()
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
            
        }
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        priceLbl.text = "\(currentStock.price)"
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        priceLbl.text = "\(currentStock.price)"
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        // Redraw chart on rotation
        chart.setNeedsDisplay()
        
    }
    
    
}

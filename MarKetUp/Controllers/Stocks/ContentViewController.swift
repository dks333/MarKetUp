//
//  ContentViewController.swift
//  MarKetUp
//
//  Created by Sam Ding on 11/10/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import UIKit
import SwiftChart

struct fetchedStock{
    let key : String
    let value : Dictionary<String, Any>
}

class ContentViewController: UIViewController {
    
    var chart: Chart!{
        didSet {
            
            view.addSubview(chart)
            chart.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                chart.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 30),
                chart.widthAnchor.constraint(equalTo: self.view.widthAnchor),
                chart.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                chart.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }
    
    var ai : UIActivityIndicatorView!{
        didSet{
            view.addSubview(ai)
            view.bringSubviewToFront(ai)
            
            ai.style = .medium
            ai.startAnimating()
            ai.center = self.view.center
            ai.color = .white
            
            ai.translatesAutoresizingMaskIntoConstraints = false
                       NSLayoutConstraint.activate([
                           ai.topAnchor.constraint(equalTo: self.view.topAnchor),
                           ai.widthAnchor.constraint(equalTo: self.view.widthAnchor),
                           ai.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                           ai.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
                       ])
        }
    }
    
    


    var content: String!
    var currentStock = Stock()
    
    var seriesData: [Double] = []
    var labels: [Double] = [] {
        didSet{
            for i in 0..<78 {
                labels.append(Double(i))
            }
        }
    }
    var labelsAsString: Array<String> = []


    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupView()
        initializeChart()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let parentVC = self.parent as! IndividualStockViewController
        parentVC.setUpTimeLbl(period: content)
        super.viewWillAppear(animated)
    }
    
    private func setupView(){
        view.backgroundColor = .clear
        chart = Chart(frame: CGRect(x: 0, y: 30, width: view.frame.width, height: view.frame.height - 10))
        ai = UIActivityIndicatorView(frame: CGRect(x: 0, y: 102, width: view.frame.width, height: view.frame.height - 10))
        
        // Chart
        chart.delegate = self
    
        chart.hideHighlightLineOnTouchEnd = true

        let parentVC = self.parent as! IndividualStockViewController
        parentVC.labelLeadingMarginInitialConstant = parentVC.labelLeadingMarginConstraint.constant
        
        parentVC.setUpTimeLbl(period: content)
        
        // Before data finish loading
        self.chart.isUserInteractionEnabled = false
    }
    
    
    override func didMove(toParent parent: UIViewController?) {
        
    }
    
    
}



extension ContentViewController: ChartDelegate{
    
    
    // Get URL String will be used as fetching stock data
    func getURL() -> String {
        
        let symbolStr = currentStock.symbol
        var url = ""
    
        
        switch content {
        case "1D":
            url = "https://intraday.worldtradingdata.com/api/v1/intraday?symbol=\(symbolStr)&range=1&interval=5&sort=asc&api_token=\(WorldTradingDataAPIKey)"
          
        case "1W":
            url = "https://intraday.worldtradingdata.com/api/v1/intraday?symbol=\(symbolStr)&range=7&interval=15&sort=asc&api_token=\(WorldTradingDataAPIKey)"
           
        case "1M":
            url = "https://intraday.worldtradingdata.com/api/v1/intraday?symbol=\(symbolStr)&range=30&interval=60&sort=asc&api_token=\(WorldTradingDataAPIKey)"

        case "3M":
            let threeMonths = Calendar.current.date(byAdding: .month, value: -3, to: Date())
            let dateFrom = threeMonths?.description.prefix(10)
            url = "https://api.worldtradingdata.com/api/v1/history?symbol=\(symbolStr)&sort=oldest&date_from=" + dateFrom! + "&api_token=\(WorldTradingDataAPIKey)"

        case "1Y":
            let oneYear = Calendar.current.date(byAdding: .year, value: -1, to: Date())
            let dateFrom = oneYear?.description.prefix(10)
            url = "https://api.worldtradingdata.com/api/v1/history?symbol=\(symbolStr)&sort=oldest&date_from=" + dateFrom! + "&api_token=\(WorldTradingDataAPIKey)"

        case "5Y":
            let fiveYears = Calendar.current.date(byAdding: .year, value: -5, to: Date())
            let dateFrom = fiveYears?.description.prefix(10)
            url = "https://api.worldtradingdata.com/api/v1/history?symbol=\(symbolStr)&sort=oldest&date_from=" + dateFrom! + "&api_token=\(WorldTradingDataAPIKey)"
            
        default:
            url = "https://api.worldtradingdata.com/api/v1/history?symbol=\(symbolStr)&sort=oldest&date_from=2019-08-10&api_token=\(WorldTradingDataAPIKey)"
        }
        
        return url
        
    }
    
    func initializeChart() {
        
        guard let url = URL(string: getURL()) else {return}

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
           guard let dataResponse = data,
               error == nil else {
                   print(error?.localizedDescription ?? "Response Error")
                   return }
           do{
               //here dataResponse received from a network request
            let jsonResponse = try JSONSerialization.jsonObject(with:
                   dataResponse, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject

            var sortedDataArray = [fetchedStock]()
            if ["1D","1W", "1M"].contains(self.content) {
                guard let dataArray = jsonResponse["intraday"] as? Dictionary<String, AnyObject> else { return }
                sortedDataArray = dataArray.map{ fetchedStock(key: $0.0, value: $0.1 as! Dictionary<String, Any>)}.sorted(by: {$0.key < $1.key})
            } else {
                guard let dataArray = jsonResponse["history"] as? Dictionary<String, AnyObject> else { return }
                sortedDataArray = dataArray.map{ fetchedStock(key: $0.0, value: $0.1 as! Dictionary<String, Any>)}.sorted(by: {$0.key < $1.key})
            }

            
            var enumeratedNum = 0
            
            for i in sortedDataArray{
                self.seriesData.append(Double(Float(i.value["close"] as? String ?? "") ?? 0.0))
                //self.labels.append(Double(enumeratedNum))
                
                if ["1D"].contains(self.content) {
                    let start = i.key.index(i.key.startIndex, offsetBy: 11)
                    let end = i.key.index(i.key.endIndex, offsetBy: -3)
                    let range = start..<end

                    let mySubstring = i.key[range]  // play
                    self.labelsAsString.append(String(mySubstring))
                
                } else {
                    self.labelsAsString.append(i.key)
                }

                enumeratedNum += 1
            }
            
            DispatchQueue.main.async {
                // After load up data
                self.ai.stopAnimating()
                self.chart.isUserInteractionEnabled = true
                
                let series = ChartSeries(self.seriesData)
                series.area = true
               
                // Configure chart layout
                self.chart.lineWidth = 1
                self.chart.areaAlphaComponent = 0.07
                
                self.chart.showYLabelsAndGrid = false
                self.chart.showXLabelsAndGrid = false
                self.chart.xLabels = self.labels
                
                // TODO: Some stocks may have different number of <labelAsString>
                // 拿一个现实的时间，然后divide by 5， if 时间 == key, get(value), else : get(lastValue)
                //self.chartWidthConstraint = self.chartWidthConstraint.setMultiplier(1 / 78 * CGFloat(self.labelsAsString.count))
                
                self.chart.gridColor = .white
                self.chart.maxY = self.seriesData.max()! * 1.001
                self.chart.minY = self.seriesData.min()! * 0.999
                self.chart.labelColor = .white
                self.chart.highlightLineColor = .white

                if self.content == "1D" {
                    series.colors = (
                        above: .lightGreen,
                        below: .customRed,
                        zeroLevel: Double(self.currentStock.close_yesterday)
                    )
                } else {
                    if self.seriesData.first! <= self.seriesData.last! {
                        series.color = .lightGreen
                    } else {
                        series.color = .customRed
                    }
                }
                
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
            let valueStr = numberFormatter.string(from: NSNumber(value: value))
            let parentVC = self.parent as! IndividualStockViewController
            parentVC.priceLbl.text = valueStr
            
            var percentage : Double = 0
            
            if content == "1D" {
                percentage = (value/Double(currentStock.close_yesterday) - 1.0) * 100.0
            } else {
                percentage = (value/seriesData[0] - 1.0) * 100.0
            }

            // Show percentage
            if percentage < 0.0 {
                // Negative
                percentage *= -1.0
                parentVC.percentageLbl.text = "-\(numberFormatter.string(from: NSNumber(value: percentage)) ?? "0.0")%"
                parentVC.percentageLbl.textColor = .customRed

            } else {
                // Positive
                parentVC.percentageLbl.text = "\(numberFormatter.string(from: NSNumber(value: percentage)) ?? "0.0")%"
                parentVC.percentageLbl.textColor = .custumGreen
            }

            // Only presenting the time, NOT DATE
            parentVC.timeLbl.textColor = .lightGray
            parentVC.timeLbl.text = labelsAsString[Int(x.rounded())]

            // Align the label to the touch left position, centered
            var constant = parentVC.labelLeadingMarginInitialConstant + left - parentVC.timeLbl.frame.width/2

            // Avoid placing the label on the left of the chart
            if constant < parentVC.labelLeadingMarginInitialConstant {
                constant = parentVC.labelLeadingMarginInitialConstant
            }

            // Avoid placing the label on the right of the chart
            let rightMargin = chart.frame.width - parentVC.timeLbl.frame.width
            if constant > rightMargin {
                constant = rightMargin
            }

            parentVC.labelLeadingMarginConstraint.constant = constant
        }
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        let parentVC = self.parent as! IndividualStockViewController
        parentVC.priceLbl.text = "\(currentStock.price)"
        parentVC.percentageLbl.text = "\(currentStock.change_pct)"
        parentVC.checkIncOrDec()
        parentVC.setUpTimeLbl(period: content)

    }
    
    func didEndTouchingChart(_ chart: Chart) {
        let parentVC = self.parent as! IndividualStockViewController
        parentVC.priceLbl.text = "\(currentStock.price)"
        parentVC.percentageLbl.text = "\(currentStock.change_pct)"
        parentVC.checkIncOrDec()
        parentVC.setUpTimeLbl(period: content)

    }

    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        // Redraw chart on rotation
        chart.setNeedsDisplay()
        
    }
    
    
}

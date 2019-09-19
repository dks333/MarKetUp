//
//  FirstViewController.swift
//  MarKetUp
//
//  Created by Sam Ding on 9/2/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import UIKit
import Foundation

struct StockAPI: Codable { // or Decodable
    let MetaData: String
    let TimeSeries: String
    
    init(json: [String: Any]){
        MetaData = json["Meta Data"] as? String ?? ""
        TimeSeries = json["Time Series (1min)"] as? String ?? ""
    }
}


class StockViewController: UITableViewController {
    
    var symbols = ["AAPL", "MSFT"]
    var stocks = [Stocks]()
    
    
    let AlphaVintageAPIKey = "VX24AALA4RTGKL99"
    
    @IBAction func reloadStocks(_ sender: Any) {
        loadingStocks()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadingStocks()
    
    }
    
    
    private func loadingStocks(){
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            for symbol in self.symbols {
                if self.presentedViewController as? UIAlertController == nil{
                    self.fetchStockData(symbol)
                }
            }
        }
    }
    
    func fetchStockData(_ symbol: String) {
        
        let url = URL(string: "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=\(symbol)&interval=1min&apikey=\(AlphaVintageAPIKey)")
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print ("ERROR")
            } else {
                if let content = data {
                    do {
                        
                        let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        
                        // Warning: if the API has reached its limit
                        if let limit = myJson["Note"] as? String {
                            print("\(symbol) didn't get to be called because Warning: `\(limit)`")
                            
                            DispatchQueue.main.async {
                                //Set an alert controller if API has reach its limit
                                if self.presentedViewController as? UIAlertController == nil{
                                    let APILimitAlert = UIAlertController(title: "Reach API requests limit", message: nil, preferredStyle: .alert)
                                    APILimitAlert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
                                    APILimitAlert.message = limit
                                    
                                    self.present(APILimitAlert, animated: true, completion: nil)
                                }
                            }
                            
                        }
                        
                        // Get the lastest time refreshed
                        var lastRefreshedTime = ""
                        if let metaData = myJson["Meta Data"] as? NSDictionary {
                            lastRefreshedTime = metaData["3. Last Refreshed"] as! String
                        }
                        
                        // Get the lastest price
                        if let time = myJson["Time Series (1min)"] as? NSDictionary  {
                            let timeBlock = time[lastRefreshedTime]! as? NSDictionary
                            let closedPriceStr = timeBlock!["4. close"] as! String
                            let closedPrice = (closedPriceStr as NSString).floatValue
                            for i in 0..<self.stocks.count {
                                if self.stocks[i].quote == symbol {
                                    self.stocks[i].currentPrice = closedPrice
                                    self.stocks[i].percentage = "1.23%"
                                }
                            }
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            print("done fetch \(symbol)")
                        }
                        
                    }  catch  {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        task.resume()
    }
    
    
    
    private func setupView(){
        //TODO: to get user's stock list
        for i in symbols {
            stocks.append(Stocks(quote: i, currentPrice: 0.00, percentage: "0%"))
        }
        
        // Clear separators of empty rows
        tableView.tableFooterView = UIView()
        

    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if stocks.count > 0 {
            return stocks.count
        } else {
            return 10
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stockCell", for: indexPath) as! StockTableViewCell
        
        let stock = stocks[indexPath.row]
        cell.setup(quote: stock.quote, price: stock.currentPrice, percentage: stock.percentage)
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "IndividualStockViewController") as! IndividualStockViewController
        let selectedStock = stocks[indexPath.row]
        vc.stockName = selectedStock.quote
        vc.stockPrice = selectedStock.currentPrice
        vc.stockPercentage = selectedStock.percentage
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        tableView.headerView(forSection: section)?.backgroundColor = .black
//        if section == 0 {
//            return "Stocks"
//        } else {
//            return "Watchlists"
//        }
//    }
    
    

    

    

}

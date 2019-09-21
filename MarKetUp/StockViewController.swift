//
//  FirstViewController.swift
//  MarKetUp
//
//  Created by Sam Ding on 9/2/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import UIKit
import Foundation



class StockViewController: UITableViewController {
    
    var symbols = ["AAPL", "MSFT", "AMZN"]
    var stocks = [Stock]()
    
    
    let AlphaVintageAPIKey = "VX24AALA4RTGKL99"
    let WorldTradingDataAPIKey = "fhGOT6U6HafLz2aazzTXti58aetYaJNZAr6cZzkibkcMut0p2MMgbgMLEDNv"
    

    
    @IBOutlet weak var profileView: UIView!
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
            if self.presentedViewController as? UIAlertController == nil{
                self.fetchStockData()
            }
        }
    }
    
    func fetchStockData() {

        let allSymbolStr = symbols.joined(separator: ",") //Ex: 'MSFT,AAPL,...'
        
        guard let url = URL(string: "https://api.worldtradingdata.com/api/v1/stock?symbol=\(allSymbolStr),&api_token=\(WorldTradingDataAPIKey)") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
            do{
                //here dataResponse received from a network request
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                guard let dataArray = jsonResponse["data"] as? [[String: Any]] else { return }
                
                // creating stock objects
                self.stocks = dataArray.compactMap{Stock($0)}
                
               
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }

                //printing the message that WorldTradingData states:
                // Ex: 'You requested 6 stocks but your account maximum is 5. Upgrade your account to increase the number of stocks available per request.'
                
                if let reachedMaxError = jsonResponse["message"] as? String {
                    print(reachedMaxError)
                    DispatchQueue.main.async {
                        //Set an alert controller if API has reach its limit
                        if self.presentedViewController as? UIAlertController == nil{
                            let APILimitAlert = UIAlertController(title: "Reach API requests limit", message: nil, preferredStyle: .alert)
                            APILimitAlert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
                            APILimitAlert.message = reachedMaxError

                            self.present(APILimitAlert, animated: true, completion: nil)
                        }
                    }
                }
                
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
        
        
        
        
        
        
        
//        let url = URL(string: "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=\(symbol)&interval=1min&apikey=\(AlphaVintageAPIKey)")
//
//        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
//            if error != nil {
//                print ("ERROR")
//            } else {
//                if let content = data {
//                    do {
//
//                        let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
//
//                        // Warning: if the API has reached its limit
//                        if let limit = myJson["Note"] as? String {
//                            print("\(symbol) didn't get to be called because Warning: `\(limit)`")
//
//                            DispatchQueue.main.async {
//                                //Set an alert controller if API has reach its limit
//                                if self.presentedViewController as? UIAlertController == nil{
//                                    let APILimitAlert = UIAlertController(title: "Reach API requests limit", message: nil, preferredStyle: .alert)
//                                    APILimitAlert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
//                                    APILimitAlert.message = limit
//
//                                    self.present(APILimitAlert, animated: true, completion: nil)
//                                }
//                            }
//
//                        }
//
//                        // Get the lastest time refreshed
//                        var lastRefreshedTime = ""
//                        if let metaData = myJson["Meta Data"] as? NSDictionary {
//                            lastRefreshedTime = metaData["3. Last Refreshed"] as! String
//                        }
//
//                        // Get the lastest price
//                        if let time = myJson["Time Series (1min)"] as? NSDictionary  {
//                            let timeBlock = time[lastRefreshedTime]! as? NSDictionary
//                            let closedPriceStr = timeBlock!["4. close"] as! String
//                            let closedPrice = (closedPriceStr as NSString).floatValue
//                            for i in 0..<self.stocks.count {
//                                if self.stocks[i].quote == symbol {
//                                    self.stocks[i].currentPrice = closedPrice
//                                    self.stocks[i].percentage = "1.23%"
//                                }
//                            }
//                            DispatchQueue.main.async {
//                                self.tableView.reloadData()
//                            }
//                            print("done fetch \(symbol)")
//                        }
//
//                    }  catch  {
//                        print(error.localizedDescription)
//                    }
//                }
//            }
//        }
//        task.resume()
    }
    
    
    
    private func setupView(){
        //TODO: to get user's stock list
        for symbol in symbols {
            //default values for each stock if App is not fetching the data
            stocks.append(Stock(symbol: symbol, price: 0.00, change_pct: "0.0%", name: symbol, day_change: "0.0", volumn: 0))
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
        cell.setup(quote: stock.symbol, price: stock.price, percentage: stock.change_pct)
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "IndividualStockViewController") as! IndividualStockViewController
        let selectedStock = stocks[indexPath.row]
        vc.currentStock = selectedStock
        
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


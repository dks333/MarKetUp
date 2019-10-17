//
//  FirstViewController.swift
//  MarKetUp
//
//  Created by Sam Ding on 9/2/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import UIKit
import Foundation

let WorldTradingDataAPIKey = "fhGOT6U6HafLz2aazzTXti58aetYaJNZAr6cZzkibkcMut0p2MMgbgMLEDNv"

var user = User(userId: "testID", cashes: 10000, values: 0, ownedStocks: [Stock(symbol: "AAPL")], watchList: [Stock(symbol: "TSLA")], ownedStocksShares: [Stock(symbol: "AAPL"):3])

class StockViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableview: UITableView!
    var symbols : [String] {
        get {
            let s1 = user.watchList.map({$0.symbol})
            let s2 = user.ownedStocks.map({$0.symbol})
            return s1+s2
        }
    }
    var stocks = [Stock]()
    
    static let APIRequestLimit = 5
    
    @IBOutlet weak var profileView: UIView!
    @IBAction func reloadStocks(_ sender: Any) {
        loadingStocks()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableview.reloadData()
    }
    
    
    // Loading Data which called fetchStockData()
    func loadingStocks(){
        
        if self.presentedViewController as? UIAlertController == nil{
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                self.fetchStockData()
            }
        }
    }
    
    //fetch data from API
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
                
                for stock in self.stocks {
                    if user.ownedStocks.contains(stock){
                        user.setOwnedStock(stock: stock)
                    } else if user.watchList.contains(stock){
                        user.setWatchList(stock: stock)
                    }
                }
                
               
                DispatchQueue.main.async {
                    self.tableview.reloadData()
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
        
    }
    
    
    
    private func setupView(){
        //TODO: to get user's stock list
        for symbol in symbols {
            //default values for each stock if App is not fetching the data
            stocks.append(Stock(symbol: symbol, price: 0.00, change_pct: "0.0%", name: symbol, day_change: "+0.0", volumn: 0))
        }
        
        // Clear separators of empty rows
        tableview.tableFooterView = UIView()
        
    }
    
    @IBAction func switchChanges(_ sender: Any) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if switchBtnPressed {
            switchBtnPressed = false
        } else {
            switchBtnPressed = true
        }
        tableview.reloadData()
    }
    
    
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: tableView.sectionHeaderHeight)) //set these values as necessary
        returnedView.backgroundColor = .clear

        let label = UILabel(frame: CGRect(x: 17, y: 0, width: self.view.frame.width, height: tableView.sectionHeaderHeight))
        label.textColor = .gray
        switch section {
        case 0:
            label.text = "Stocks"
            break
        case 1:
            label.text = "Watchlist"
            break
        default:
            break
        }
        returnedView.addSubview(label)

        return returnedView
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch (section) {
            case 0:
                return user.ownedStocks.count
            case 1:
                return user.watchList.count
            default:
               return 1
         }
    }


    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stockCell", for: indexPath) as! StockTableViewCell
        
        
        switch (indexPath.section) {
        case 0:
            let stock = user.ownedStocks[indexPath.row]
            cell.setup(quote: stock.symbol, price: stock.price, percentage: stock.change_pct, dayChange: stock.day_change)
            
            break
              
        case 1:
            let stock = user.watchList[indexPath.row]
            cell.setup(quote: stock.symbol, price: stock.price, percentage: stock.change_pct, dayChange: stock.day_change)
            
            break
        default: break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "IndividualStockViewController") as! IndividualStockViewController
        switch indexPath.section{
        case 0:
            let selectedStock = user.ownedStocks[indexPath.row]
            vc.currentStock = selectedStock
            break
        case 1:
            let selectedStock = user.watchList[indexPath.row]
            vc.currentStock = selectedStock
            break
        default: break
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
        
    }
    

    
    

    

}


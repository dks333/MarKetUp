//
//  FirstViewController.swift
//  MarKetUp
//
//  Created by Sam Ding on 9/2/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import UIKit
import Foundation
import CoreData

let WorldTradingDataAPIKey = "fhGOT6U6HafLz2aazzTXti58aetYaJNZAr6cZzkibkcMut0p2MMgbgMLEDNv"

class StockViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var tableview: UITableView!
    @IBOutlet weak var searchBtn: UIButton! {
        didSet{
            searchBtn.layer.borderWidth = 1
            searchBtn.layer.cornerRadius = 10
            searchBtn.layer.borderColor = UIColor.custumGreen.cgColor
        }
    }
    
    @IBOutlet weak var totalValueLbl: UILabel!
    @IBOutlet weak var valueChangedLbl: UILabel!
    @IBOutlet weak var percentChangedLbl: UILabel!
    
    
    func getSymbols() -> [String]{
        let s1 = User.shared.watchList.map({$0.symbol})
        let s2 = User.shared.ownedStocks.map({$0.symbol})
        // Getting Unique symbols
        let uniqueSymbols = Array(Set(s1 + s2))
        return uniqueSymbols
    }
    
    var stocks = [Stock]()
    var watchList = [WatchList]()
    var storedStock = [StoredStock]()
    var stockHistory = [StockHistory]()
    
    let APIRequestLimit = 50
    var loadingTimer = Timer()
    
    var yesterdayTotalValues : Float = 0.0
    var valueChanged: Float = 0.0
    var percentChanged: Float = 0.0
    
    var numberFormatter = NumberFormatter()
    
    @IBOutlet weak var profileView: UIView!

    @objc func loadStocks(){

        loadingStocks()   // TODO: Uncomment this line
        print("refreshed")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let firstRun = UserDefaults.standard.bool(forKey: "firstRun") as Bool
        if !firstRun {
            User.shared.setCash()
            setUpDefault()
            UserDefaults.standard.set(true, forKey: "firstRun")
        }
        
        //UserDefaults.standard.removeObject(forKey: "RemovedAds")
        if UserDefaults.standard.value(forKey: "check") == nil {
            UserDefaults.standard.setValue(Date(), forKey: "storedDate")
            UserDefaults.standard.setValue(10000.0, forKey: "storedTotalValues")
            UserDefaults.standard.setValue(true, forKey: "check")
        }

        // Refresh Stocks every ONE minute
        loadingTimer = Timer.scheduledTimer(timeInterval: 65.0, target: self, selector: #selector(self.loadStocks), userInfo: nil, repeats: true)
        loadingTimer.fire()
        
        setupView()

        
        fetchWatchList()
        fetchStockList()
        
        if getSymbols().count != 0{
            loadingStocks()
        }
        
        setLocalYesterdayTotalValue()
        
        
    }
    
    private func setUpDefault(){
        UserDefaults.standard.setValue(0.0, forKey: "valueChanged")
        UserDefaults.standard.setValue(0.0, forKey: "chargedCash")
    }
    
    private var timer = Timer(timeInterval: 60.0, repeats: false) { _ in print("Done!") }
    
    
    // Fetching WatchList from Core Data
    private func fetchWatchList(){
        let fetchRequest: NSFetchRequest<WatchList> = WatchList.fetchRequest()
        
        do {
            let watchList = try PersistenceServce.context.fetch(fetchRequest)
            self.watchList = watchList
        } catch {}
        
        
        for stock in watchList {
            User.shared.watchList.append(Stock(symbol: stock.symbol))
        }
    }
    
    // Fetching Stock List from Core Data
    private func fetchStockList(){
        let fetchRequest: NSFetchRequest<StoredStock> = StoredStock.fetchRequest()
        
        do {
            let storedStock = try PersistenceServce.context.fetch(fetchRequest)
            self.storedStock = storedStock
        } catch {}
        
        var totalValues : Float = 0.0

        for stock in storedStock {
            let addedStock = Stock(symbol: stock.symbol)
            User.shared.ownedStocks.append(addedStock)
            User.shared.ownedStocksShares[addedStock] = Int(stock.shares)
            totalValues += Float(User.shared.ownedStocksShares[addedStock]!) * stock.buyingPrice
            
        }
        
        // Set up User info
        User.shared.values = totalValues
        User.shared.cashes = UserDefaults.standard.value(forKey: "cash") as! Float
        let totalValueStr = numberFormatter.string(from: NSNumber(value:  UserDefaults.standard.value(forKey: "storedTotalValues") as! Float))!
        totalValueLbl.text = "$" + totalValueStr
        
    }
    
    private func setLocalYesterdayTotalValue(){
        self.yesterdayTotalValues = User.shared.getTotalValues()
        
    }
    
    func getStoredStocks(stock: Stock){
        let stockWithSymbolOnly = WatchList(context: PersistenceServce.context)
        stockWithSymbolOnly.symbol = stock.symbol
        PersistenceServce.saveContext()
        self.watchList.append(stockWithSymbolOnly)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDataBeforeViewLoad()
    }
    
    fileprivate var checkFirstLoadTotalValueLbl = false
    
    // Helper method for viewWillAppear
    private func updateDataBeforeViewLoad(){
        if checkFirstLoadTotalValueLbl {
            totalValueLbl.text = "$" + numberFormatter.string(from: NSNumber(value: User.shared.getTotalValues()))!
        } else {
            checkFirstLoadTotalValueLbl = true
        }
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
        let Symbols = getSymbols()
        print(Symbols)
        let cycle = Int((Float(Symbols.count)/Float(APIRequestLimit)).rounded(.up))
        var tempSymbols = Symbols
        print("-----tempsyombols---------")
        print(tempSymbols)
        for _ in 0..<cycle {
            let allSymbllStr = tempSymbols.prefix(self.APIRequestLimit).joined(separator: ",")
            tempSymbols = Array(tempSymbols.dropFirst(self.APIRequestLimit))
            
            guard let url = URL(string: "https://api.worldtradingdata.com/api/v1/stock?symbol=\(allSymbllStr),&api_token=\(WorldTradingDataAPIKey)") else { return }
                   
                   let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                       guard let dataResponse = data,
                           error == nil else {
                               print(error?.localizedDescription ?? "Response Error")
                            // Cannot Access the network
                            DispatchQueue.main.async {
                                
                                if self.presentedViewController as? UIAlertController == nil{
                                    let NetworkAlert = UIAlertController(title: "Network Error", message: nil, preferredStyle: .alert)
                                    NetworkAlert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
                                    NetworkAlert.message = "Please check you network connection"

                                    self.present(NetworkAlert, animated: true, completion: nil)
                                }
                            }
                               return }
                       do{
                           //here dataResponse received from a network request
                           let jsonResponse = try JSONSerialization.jsonObject(with:
                               dataResponse, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                           guard let dataArray = jsonResponse["data"] as? [[String: Any]] else { return }
                           let tradeDay = dataArray[0]["last_trade_time"] as! String
                           let date = self.checkIfToday(tradeDay: tradeDay)

                           // creating stock objects
                           self.stocks = dataArray.compactMap{Stock($0)}
                           // reset values
                           var totalValues : Float = 0.0
                        
                        
                           for stock in self.stocks {
                               
                               //self.getStoredStocks(stock: stock)
                               if User.shared.ownedStocks.contains(stock){
                                   User.shared.setOwnedStock(stock: stock)
                                   let index = User.shared.ownedStocks.firstIndex(of: stock)
                                   totalValues += Float(User.shared.ownedStocksShares[stock]!) * User.shared.ownedStocks[index!].price
                               }
                               if User.shared.watchList.contains(stock){
                                   User.shared.setWatchList(stock: stock)
                               }
                               
                           }
                        
                           User.shared.values = totalValues
                           // Two sub labels calculation
                        
                           if  Date() > date.advanced(by: 28800) {  //  hours later
                            
                               print("Changed total values to latest")
                               UserDefaults.standard.setValue(Date(), forKey: "storedDate")
                               UserDefaults.standard.setValue(User.shared.getTotalValues(), forKey: "storedTotalValues")
                               self.yesterdayTotalValues = User.shared.getTotalValues()
                               // 超过trading 时间不能trade

                           } else {
                                print("============")

                                self.yesterdayTotalValues = UserDefaults.standard.value(forKey: "storedTotalValues") as! Float
                           }
                        
                           self.valueChanged = User.shared.getTotalValues() - self.yesterdayTotalValues
                           self.percentChanged = (User.shared.getTotalValues() - self.yesterdayTotalValues) * 100.0 / self.yesterdayTotalValues
                           
                        
                            DispatchQueue.main.async {
                                self.tableview.reloadData()
                                
                                print("====== totalValuesyesterday =======")
                                print(self.yesterdayTotalValues)
                                
                                self.valueChangedLbl.text = self.numberFormatter.string(from: NSNumber(value: self.valueChanged))
                                self.percentChangedLbl.text = self.numberFormatter.string(from: NSNumber(value: self.percentChanged))!+"%"
                                
                                if self.valueChanged < 0 {
                                    self.valueChangedLbl.textColor = .customRed
                                    self.percentChangedLbl.textColor = .customRed
                                } else {
                                    self.valueChangedLbl.textColor = .lightGreen
                                    self.percentChangedLbl.textColor = .lightGreen
                                    self.valueChangedLbl.text = "+" + self.valueChangedLbl.text!
                                    self.percentChangedLbl.text = "+" + self.percentChangedLbl.text!
                                    
                                }
                                self.totalValueLbl.textColor = .white
                                self.totalValueLbl.text = "$" + self.numberFormatter.string(from: NSNumber(value: User.shared.getTotalValues()))!
                                
                                
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
        
    }
    
    // check the date if it is today
    fileprivate func checkIfToday(tradeDay: String) -> Date{
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC-5")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from:String(tradeDay.prefix(20)))!
        
        return date
        
    }
    
    
    // Set up all Views
    private func setupView(){
        
        // Set up number formatter
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2

        for symbol in getSymbols() {
            //default values for each stock if App is not fetching the data
            stocks.append(Stock(symbol: symbol, price: 0.00, change_pct: "0.0%", name: symbol, day_change: "+0.0", volumn: 0))
        }
        
        // Clear separators of empty rows
        tableview.tableFooterView = UIView()
        
        // set default
        User.shared.chargedCash = UserDefaults.standard.value(forKey: "chargedCash") as! Float
        
        // Views
        valueChangedLbl.textColor = .darkGray
        percentChangedLbl.textColor = .darkGray
        totalValueLbl.textColor = .lightGray
        
    }
    
    @IBAction func switchChanges(_ sender: Any) {

        if switchBtnPressed {
            switchBtnPressed = false
        } else {
            switchBtnPressed = true
        }
        tableview.reloadData()
    }
    
    
    

    func numberOfSections(in tableView: UITableView) -> Int {
        if User.shared.ownedStocks == [] || User.shared.watchList == []{
            return 1
        }
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: tableView.sectionHeaderHeight)) //set these values as necessary
        returnedView.backgroundColor = .black


        let label = UILabel(frame: CGRect(x: 17, y: 0, width: self.view.frame.width, height: tableView.sectionHeaderHeight))
        label.textColor = .gray
        
        if User.shared.ownedStocks == []{
            // If no stocks purchased
            label.text = "WatchList"
            if User.shared.watchList == [] {
                label.textAlignment = .center
                label.text = "Search to add stocks"
            }
        } else if User.shared.watchList == [] && User.shared.ownedStocks != []{
            label.text = "Stocks"
        } else {
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
        }
        returnedView.addSubview(label)

        return returnedView
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if User.shared.ownedStocks == [] {
            // If no stocks purchased
            return User.shared.watchList.count
        } else if User.shared.watchList == [] {
            return User.shared.ownedStocks.count
        }
        
        switch (section) {
            case 0:
                return User.shared.ownedStocks.count
            case 1:
                return User.shared.watchList.count
            default:
               return 1
         }
    }


    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stockCell", for: indexPath) as! StockTableViewCell
        
        if User.shared.ownedStocks == [] {
            // If no stocks purchased
            let stock = User.shared.watchList[indexPath.row]
        
            
            cell.setup(quote: stock.symbol, price: stock.price, percentage: stock.change_pct, dayChange: stock.day_change)
            cell.setUpNumOfShares(numOfShare: "")
            
        }else if User.shared.watchList == []{
            let stock = User.shared.ownedStocks[indexPath.row]
            
            cell.setup(quote: stock.symbol, price: stock.price, percentage: stock.change_pct, dayChange: stock.day_change)
            if let shares = User.shared.ownedStocksShares[stock] {
                // Set up stock share lbl
                if shares == 1 {
                    cell.setUpNumOfShares(numOfShare: "\(String(describing: User.shared.ownedStocksShares[stock]!)) share")
                } else {
                    cell.setUpNumOfShares(numOfShare: "\(String(describing: User.shared.ownedStocksShares[stock]!)) shares")
                }
            }
    
        } else {
            switch (indexPath.section) {
            case 0:
                // Stocks
                let stock = User.shared.ownedStocks[indexPath.row]
                
                cell.setup(quote: stock.symbol, price: stock.price, percentage: stock.change_pct, dayChange: stock.day_change)
                if let shares = User.shared.ownedStocksShares[stock] {
                    // Set up stock share lbl
                    if shares == 1 {
                        cell.setUpNumOfShares(numOfShare: "\(String(describing: User.shared.ownedStocksShares[stock]!)) share")
                    } else {
                        cell.setUpNumOfShares(numOfShare: "\(String(describing: User.shared.ownedStocksShares[stock]!)) shares")
                    }
                }

                break
                  
            case 1:
                // watchList
                let stock = User.shared.watchList[indexPath.row]

                
                cell.setup(quote: stock.symbol, price: stock.price, percentage: stock.change_pct, dayChange: stock.day_change)
                cell.setUpNumOfShares(numOfShare: "")
                

                
                break
            default: break
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "IndividualStockViewController") as! IndividualStockViewController
        if User.shared.ownedStocks == [] {
            // If no stocks purchased
            let selectedStock = User.shared.watchList[indexPath.row]
            vc.currentStock = selectedStock
            
        }else if User.shared.watchList == []{
            let selectedStock = User.shared.ownedStocks[indexPath.row]
            vc.currentStock = selectedStock
            
        } else {
            switch indexPath.section{
            case 0:
                let selectedStock = User.shared.ownedStocks[indexPath.row]
                vc.currentStock = selectedStock
                break
            case 1:
                let selectedStock = User.shared.watchList[indexPath.row]
                vc.currentStock = selectedStock
                break
            default: break
            }
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
        
    }
    

    
    

    

}


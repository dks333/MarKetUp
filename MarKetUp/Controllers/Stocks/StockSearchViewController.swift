//
//  StoclSearchViewController.swift
//  MarKetUp
//
//  Created by Sam Ding on 9/22/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class StockSearchViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate {
    

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchController = UISearchController(searchResultsController: nil)
    
    var filteredStocks = [Stock]()
    var stocks = [Stock]()
    
    var addedStocks = [Stock]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        DispatchQueue.global(qos: .userInitiated).async {
            self.loadUpStocks()
        }
    }
    
    private func loadUpStocks(){
        
//        guard let url = URL(string: "https://api.worldtradingdata.com/api/v1/ticker_list?type=stocks&api_token=\(WorldTradingDataAPIKey)") else { return }
//
//        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//            guard let dataResponse = data,
//                error == nil else {
//                    print(error?.localizedDescription ?? "Response Error")
//                    return }
//            do{
//                //here dataResponse received from a network request
//                let jsonResponse = try JSONSerialization.jsonObject(with:
//                    dataResponse, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
//                guard let dataArray = jsonResponse["data"] as? [[String: Any]] else { return }
//
//                //add stock name and symbol into Stock
//                self.stocks = dataArray.compactMap{Stock($0)}
//
//            } catch let parsingError {
//                print("Error", parsingError)
//            }
//        }
//        task.resume()
        
        if let path = Bundle.main.path(forResource: "StockList2019:10:14", ofType: "json") {
                   do {
                         let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                         let jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                         guard let dataArray = jsonResponse as? [[String: Any]] else { return }
                         //add stock name and symbol into Stocks
                         self.stocks = dataArray.compactMap{Stock($0)}
                     } catch {
                          // handle error
                     }
               }
    }
    
    private func search(input: String){
//        guard let url = URL(string: "https://api.worldtradingdata.com/api/v1/stock_search?search_term=\(input)&stock_exchange=NASDAQ,NYSE&currency=USD&search_by=symbol,name&limit=50&page=1&api_token=\(WorldTradingDataAPIKey)") else { return }
//
//        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//            guard let dataResponse = data,
//                error == nil else {
//                    print(error?.localizedDescription ?? "Response Error")
//                    return }
//            do{
//                //here dataResponse received from a network request
//                let jsonResponse = try JSONSerialization.jsonObject(with:
//                    dataResponse, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
//                guard let dataArray = jsonResponse["data"] as? [[String: Any]] else { return }
//
//                //add stock name and symbol into Stock
//                self.stocks = dataArray.compactMap{Stock($0)}
//
//                DispatchQueue.main.async {
//                    self.tableview.reloadData()
//                }
//
//            } catch let parsingError {
//                print("Error", parsingError)
//            }
//        }
//        task.resume()
        
        // TODO: Optimize the searching function
        // Filter by symbol, name, ascending, inclusive
        if filteredStocks.count < 15 {
            filteredStocks = stocks.filter({$0.symbol.starts(with: input.uppercased()) || $0.name.lowercased().contains(input.lowercased())})
        } else {
            // Priority Search
            filteredStocks = stocks.filter({$0.symbol.starts(with: input.uppercased())})
        }
        
        filteredStocks = Array(filteredStocks.prefix(15))  // Getting the first 15 searched stocks
        
            
        tableview.reloadData()
        tableview.layoutIfNeeded()
        
    }
    
    private func setupView(){
        // Set up tableview
        tableview.tableFooterView = UIView()
        tableview.allowsSelection = true
        
        tableview.backgroundColor = .GrayBlack
        
        
        // Set up navigation bar
        self.navigationController?.navigationBar.tintColor = .custumGreen
        
        // Set up Searchbar
        searchBar.tintColor = .custumGreen
        searchBar.backgroundColor = .GrayBlack
        
        // Set up the responder for SearchBar
        searchBar.becomeFirstResponder()
        
        // Set up search controller
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchBar = searchController.searchBar
    }
    
    
    // Add stocks to watchlist
    @IBAction func AddStock(_ button: UIButton) {
        let selectedStock = filteredStocks[button.tag]

        if button.tintColor != .black && !User.shared.watchList.contains(selectedStock){
            button.tintColor = .black
            if !User.shared.watchList.contains(selectedStock) {
                User.shared.watchList.append(selectedStock)
                
                if !selectedStock.checkIfItemExist(symbol: selectedStock.symbol){
                    let stockWithSymbolOnly = WatchList(context: PersistenceServce.context)
                    stockWithSymbolOnly.symbol = selectedStock.symbol
                    PersistenceServce.saveContext()
                }
                
            }
        } else {
            button.tintColor = .custumGreen
            if let index = User.shared.watchList.firstIndex(of: selectedStock) {
                User.shared.watchList.remove(at: index)
                
                // Delete from Core Data
                let managedContext = PersistenceServce.context
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WatchList")
                fetchRequest.predicate = NSPredicate(format: "symbol == %@" ,selectedStock.symbol)
                do {
                    let objects = try managedContext.fetch(fetchRequest)
                    for object in objects {
                        managedContext.delete(object)
                    }
                    try managedContext.save()
                } catch _ {
                    // error handling
                    print("Cannot Delete \(selectedStock.symbol)")
                }
                
            }
            
        }
        
       
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        //self.setTabBarVisible(visible: false, animated: true)
        super.viewWillAppear(animated)
        
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        //self.setTabBarVisible(visible: true, animated: true)
        super.viewWillDisappear(animated)
        if let vc = self.presentingViewController?.children[0].children[0] as? StockViewController {

            vc.loadingStocks()
            vc.tableview.reloadData()
            vc.view.layoutIfNeeded()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.layoutIfNeeded()

    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let trimmedInput = String((searchController.searchBar.text!.filter { !" \n\t\r".contains($0) }))
        self.search(input: trimmedInput)
    }
    
}

extension StockSearchViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.tableview.keyboardDismissMode = .onDrag
        self.searchBar.endEditing(true)
        self.searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredStocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as! searchResultTableViewCell
        
        let currentStock = filteredStocks[indexPath.row]
        
        cell.nameLbl.text = currentStock.name
        cell.symbolLbl.text = currentStock.symbol
        
        if User.shared.watchList.contains(currentStock) {
            cell.addBtn.tintColor = .black
        } else {
            cell.addBtn.tintColor = .custumGreen
        }
        
        cell.addBtn.tag = indexPath.row
        return cell
    }
    
    
    
}


extension StockSearchViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            filteredStocks = []
            tableview.reloadData()
            return
        }
        
        let trimmedInput = String(searchText.filter { !" \n\t\r".contains($0) })
        self.search(input: trimmedInput)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)

    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        self.searchBar.endEditing(true)
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        self.searchBar.endEditing(true)
        searchBar.text = ""
        
        // Clear the table view
        
        performSegueToReturnBack()
        
    }
    
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}



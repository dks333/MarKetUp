//
//  StoclSearchViewController.swift
//  MarKetUp
//
//  Created by Sam Ding on 9/22/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import UIKit
import Foundation

class StockSearchViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate {
    

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    var stocks = [searchedStock]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.search(input: "AA")
        }

    }
    
    private func search(input: String){
        guard let url = URL(string: "https://api.worldtradingdata.com/api/v1/stock_search?search_term=\(input)&stock_exchange=NASDAQ,NYSE&currency=USD&search_by=symbol,name&limit=50&page=1&api_token=\(WorldTradingDataAPIKey)") else { return }
        
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
                
                //add stock name and symbol into searchedStock
                self.stocks = dataArray.compactMap{searchedStock($0)}

                DispatchQueue.main.async {
                    self.tableview.reloadData()
                }
                
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
        
    }
    
    private func setupView(){
        // Set up tableview
        tableview.tableFooterView = UIView()
        tableview.allowsSelection = false
        tableview.backgroundColor = .black
        
        // Set up navigation bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.topItem?.title = "Home"
        self.navigationController?.navigationBar.tintColor = .custumGreen
        
        // Set up Searchbar
        searchBar.tintColor = .custumGreen
    }
    
    @IBAction func AddStock(_ sender: Any) {
        print("Added Stock to Watchlist")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setTabBarVisible(visible: false, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillAppear(animated)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.setTabBarVisible(visible: true, animated: true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillDisappear(animated)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)


    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
}

extension StockSearchViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.tableview.keyboardDismissMode = .onDrag
        self.searchBar.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as! searchResultTableViewCell
        
        cell.nameLbl.text = stocks[indexPath.row].name
        cell.symbolLbl.text = stocks[indexPath.row].symbol
        
        return cell
    }
    
    
}


extension StockSearchViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //print("searchText \(searchText)")
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)

    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        self.searchBar.endEditing(true)
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        self.searchBar.endEditing(true)
        
    }
    
    
}


struct searchedStock{
    
    let name: String
    let symbol: String
    
    init(name: String, symbol: String){
        self.name = name
        self.symbol = symbol
    }
    
    init(_ dictionary: [String: Any]) {
        self.symbol = dictionary["symbol"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
    }
}

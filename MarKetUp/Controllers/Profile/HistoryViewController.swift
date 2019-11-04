//
//  HistoryViewController.swift
//  MarKetUp
//
//  Created by Sam Ding on 10/17/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: SubProfileViewController {

    @IBOutlet weak var tableview: UITableView!
    
    var stockHistory = [StockHistory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        fetchHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableview.reloadData()
    }
    
    private func fetchHistory(){
        let fetchRequest: NSFetchRequest<StockHistory> = StockHistory.fetchRequest()
        
        do {
            let stockHistory = try PersistenceServce.context.fetch(fetchRequest)
            self.stockHistory = stockHistory
            self.stockHistory.reverse()
        } catch {}
        
        self.tableview.reloadData()
    }
    
    
    private func setUpView(){
        // Clear separators of empty rows
        tableview.tableFooterView = UIView()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "historySegue" {
            let vc = segue.destination as! DetailStockHistoryViewController
            vc.currentStockHistory = stockHistory[tableview.indexPathForSelectedRow!.row]
        }
    }


}


extension HistoryViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stockHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! StockHistoryTableViewCell
        
        let history = stockHistory[indexPath.row]
        cell.symbolLbl.text = "\(history.symbol) Market \(history.type)"
        cell.dateLbl.text = "\(history.date)"
        cell.priceLbl.text = "\(history.price)"
        
        return cell
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let managedObjectContext = PersistenceServce.context
        if editingStyle == .delete {
            let deletedHistory = stockHistory[indexPath.row]
            let index = stockHistory.firstIndex(of: deletedHistory)
            
            managedObjectContext.delete(deletedHistory)
            stockHistory.remove(at: index!)
            PersistenceServce.saveContext()
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
        
      }
    }
    
}

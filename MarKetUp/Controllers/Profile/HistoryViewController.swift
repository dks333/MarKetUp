//
//  HistoryViewController.swift
//  MarKetUp
//
//  Created by Sam Ding on 10/17/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds

class HistoryViewController: SubProfileViewController {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var stockHistory = [StockHistory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        fetchHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableview.reloadData()
        if !UserDefaults.standard.bool(forKey: "RemovedAds") {
            
        } else {
            bannerView.isHidden = true
            tableview.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        }
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
    
    private func loadBannerView(){
           // Set up Google Ad Banner View
           bannerView.adUnitID = AdUnit.AdUnit  //TODO: Change this Unit Ad back when got to production
           bannerView.rootViewController = self
           bannerView.load(GADRequest())
    }
    
    private func setUpView(){
        // Clear separators of empty rows
        tableview.tableFooterView = UIView()
        loadBannerView()
        print("hahhahahhah")
        
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
        cell.priceLbl.text = "$\(history.price)"
        
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

// Google Banner View
extension HistoryViewController: GADBannerViewDelegate{

    // Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
          bannerView.alpha = 1
        })
        print("adViewDidReceiveAd")
    }

    // Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    // Tells the delegate that a full-screen view will be presented in response
    // to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }

    // Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }

    // Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }

    // Tells the delegate that a user click will open another app (such as
    // the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
}



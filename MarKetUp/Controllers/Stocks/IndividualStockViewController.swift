//
//  IndividualStockViewController.swift
//  MarKetUp
//
//  Created by Sam Ding on 9/16/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import GoogleMobileAds
import SwipeMenuViewController
import SwiftChart




class IndividualStockViewController: UIViewController {
    func changeTimeLbl(str: String) {
        print(str)
    }
    
    
    var currentStock = Stock()
    
    var seriesData: [Double] = []
    var labels: [Double] = []
    var labelsAsString: Array<String> = []
    
    //Constraints
    @IBOutlet weak var labelLeadingMarginConstraint: NSLayoutConstraint!
    var labelLeadingMarginInitialConstant: CGFloat!

    
    @IBOutlet weak var stockNameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var percentageLbl: UILabel!
    @IBOutlet weak var companyNameLbl: UILabel!
    @IBOutlet weak var cancelFollowingBtn: UIButton!
    @IBOutlet weak var timeLbl: UILabel!
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var sellStockBtn: UIButton!{
        didSet{
            if !User.shared.isHeldStock(stock: currentStock){
                sellStockBtn.isEnabled = false
                sellStockBtn.backgroundColor = .gray
            }
        }
    }
    @IBOutlet weak var buyStockBtn: UIButton!
    
    private var datas: [String] = ["1D","1W", "1M", "3M", "1Y", "5Y"]
    var swipeMenuView: SwipeMenuView!{
        didSet{
            
            swipeMenuView.options.tabView.addition = .circle
            swipeMenuView.options.tabView.style = .segmented
            swipeMenuView.options.tabView.itemView.textColor = .darkGray
            swipeMenuView.options.tabView.itemView.selectedTextColor = .black
            swipeMenuView.options.tabView.additionView.backgroundColor = .lightGreen
            swipeMenuView.options.tabView.height = 25
            swipeMenuView.options.tabView.margin = 20
            
            swipeMenuView.dataSource = self
            swipeMenuView.delegate = self

        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildVC()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.setTabBarVisible(visible: false, animated: true)
        //self.tabBarController?.tabBar.isHidden = true
        if !UserDefaults.standard.bool(forKey: "RemovedAds") {
            
        } else {
            bannerView.isHidden = true
        }
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.setTabBarVisible(visible: true, animated: true)
        //self.tabBarController?.tabBar.isHidden = false
        super.viewWillDisappear(animated)
    }
    
    // This function takes in different time periods as parameters and add UIViewController to children
    fileprivate func addChildVC(){
        datas.forEach { data in
            let vc = ContentViewController()
            vc.title = data
            vc.content = data
            vc.currentStock = self.currentStock
            self.addChild(vc)
        }
    }
    
    private func loadBannerView(){
        // Set up Google Ad Banner View
        bannerView.adUnitID = AdUnit.AdUnit  //TODO: Change this Unit Ad back when got to production
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    
    fileprivate func setupView(){
        // Load banner view
        loadBannerView()
        
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
        
        checkIncOrDec()
        
        cancelFollowingBtn.tintColor = (User.shared.watchList.contains(currentStock)) ? .darkGray : .custumGreen
        
        // CancelFollowingBtn should not present in ownedStock VC
//        if User.shared.isHeldStock(stock: currentStock) && !User.shared.watchList.contains(currentStock){
//            cancelFollowingBtn.isHidden = true
//        }
        
        // Menu View
        swipeMenuView = SwipeMenuView(frame: CGRect(x:0, y: view.frame.height * 0.25, width: view.frame.width, height: view.frame.height * 0.55))
        view.addSubview(swipeMenuView)
        
        
        timeLbl.bottomAnchor.constraint(equalTo: swipeMenuView.topAnchor, constant: 50).isActive = true
        self.view.layoutIfNeeded()
    }
    
    // Change UI for percentageLBL
    func checkIncOrDec(){
        if currentStock.change_pct.first == "-" {
           //priceLbl.textColor = .customRed
           percentageLbl.textColor = .customRed
        } else {
           //priceLbl.textColor = .custumGreen
           percentageLbl.textColor = .custumGreen
        }
    }
    
    func setUpTimeLbl(){
        timeLbl.text = "00:00"
        timeLbl.textColor = .black
    }
    
    @IBAction func sellingStocks(_ sender: Any) {
        
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
    
    
    private var index = 0
    
    @IBAction func cancelFollowing(_ sender: Any) {
         UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        if !User.shared.watchList.contains(currentStock) && User.shared.isHeldStock(stock: currentStock){
            // Storing
            cancelFollowingBtn.tintColor = .darkGray
            User.shared.addStocks(stock: currentStock, type: "watchList", index: index)
            
            // Add to database
            if !currentStock.checkIfItemExist(symbol: currentStock.symbol){
               let stockWithSymbolOnly = WatchList(context: PersistenceServce.context)
               stockWithSymbolOnly.symbol = currentStock.symbol
               PersistenceServce.saveContext()
            }
            
        } else {
            // Deleting
            index = User.shared.watchList.firstIndex(of: self.currentStock)!
            User.shared.cancelFollowingStock(stock: currentStock)
            cancelFollowingBtn.tintColor = .custumGreen
            
            // Delete from Core Data
            let managedContext = PersistenceServce.context
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WatchList")
            fetchRequest.predicate = NSPredicate(format: "symbol == %@" ,currentStock.symbol)
            do {
                let objects = try managedContext.fetch(fetchRequest)
                for object in objects {
                    managedContext.delete(object)
                }
                try managedContext.save()
            } catch _ {
                // error handling
                print("Cannot Delete \(currentStock.symbol)")
            }
        }
        
        
    }
    

}


extension IndividualStockViewController: SwipeMenuViewDelegate, SwipeMenuViewDataSource{
    

    func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return datas.count
    }

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {

        return datas[index]
    }

    func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {

        let vc = children[index]
        vc.didMove(toParent: self)
        return vc

    }
    
    
}

// Google Banner View
extension IndividualStockViewController: GADBannerViewDelegate{

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



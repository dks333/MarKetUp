//
//  ProfileViewController.swift
//  MarKetUp
//
//  Created by Sam Ding on 9/16/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

// APP ID: ca-app-pub-3091350439303516~5399968471
// AD Unit: ca-app-pub-3091350439303516/2331430931
// Test Ad: ca-app-pub-3940256099942544/2934735716

import Foundation
import UIKit
import StoreKit
import GoogleMobileAds

struct AdUnit{
    static let AdUnit = "ca-app-pub-3091350439303516/2331430931"
    static let TestID = "ca-app-pub-3940256099942544/2934735716"
}

class ProfileViewController: UIViewController{
    
    
    @IBOutlet weak var purchaseCollectionView: UICollectionView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var selectionTableView: UITableView!
    

    private var listOfPurchase = ["2.99", "0.99", "1.99", "9.99", "49.99"]
    private var purchaseItems = ["Remove ads", "5000", "20000", "300000", "3000000"]
    
    override func viewDidLoad() {
        setupView()
        setUpIAPProducts()
    }
    
    private func loadBannerView(){
        // Set up Google Ad Banner View
        bannerView.adUnitID = AdUnit.TestID  //TODO: Change this Unit Ad back when got to production
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !UserDefaults.standard.bool(forKey: "RemovedAds") {
            
        } else {
            bannerView.isHidden = true
        }
        
    }
    
    private func setUpIAPProducts(){
        IAPService.shared.getProducts()
    }
    
    private func setupView(){
        loadBannerView()
        
        bannerView.delegate = self
        
        // Navigation Bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        
    }
    

    @IBAction func restorePurchaseOfRemoveAds(_ sender: Any) {
        IAPService.shared.restorePurchases()
    }
    
}


extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell") as! ProfileSelectionOneTableViewCell

            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "stockHistoryCell") as! ProfileSelectionTwoTableViewCell

            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as! ProfileSelectionThreeTableViewCell
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell")!
            return cell
        }
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return selectionTableView.frame.height/3
    }
    
    
}


// IAP Product Collection
extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOfPurchase.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "purchaseCell", for: indexPath) as! PurchaseCollectionViewCell
        
        if indexPath.item != 0{
            cell.purchaseBtn.setTitle("+$" + purchaseItems[indexPath.item], for: .normal)
        } else {
            cell.purchaseBtn.setTitle(purchaseItems[indexPath.item], for: .normal)
        }
        cell.itemLbl.text = "$" + listOfPurchase[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch  indexPath.item {
        case 0:
            // Removing Ads
            IAPService.shared.purchase(product: .RemoveAds)
        case 1:
            // $5000 added (0.99)
            IAPService.shared.purchase(product: .LevelOneCredit)
        case 2:
            // $20000 added (1.99)
            IAPService.shared.purchase(product: .LevelTwoCredit)
        case 3:
            // $300000 added (9.99)
            IAPService.shared.purchase(product: .LevelThreeCredit)
        case 4:
            // $1000000 added (49.99)
            IAPService.shared.purchase(product: .LevelFourCredit)
        default:
            print("More incoming")
        }
    
    }
    
    
}

// Google Banner View
extension ProfileViewController: GADBannerViewDelegate{

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

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

class ProfileViewController: UIViewController{
    
    var user: User!
    
    @IBOutlet weak var purchaseCollectionView: UICollectionView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    private var listOfPurchase = ["2.99", "0.99", "1.99", "5.99", "9.99", "49.99"]
    private var purchaseItems = ["Remove ads", "1000", "2000", "10000", "50000", "300000"]
    
    override func viewDidLoad() {
        setupView()
    }
    
    private func setupView(){
        // Set up Google Ad Banner View
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"  //TODO: Change this Unit Ad back when got to production
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        bannerView.delegate = self
        
        // Navigation Bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        
    }
    
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOfPurchase.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "purchaseCell", for: indexPath) as! PurchaseCollectionViewCell
        
        if indexPath.item != 0{
            cell.purchaseBtn.setTitle("$" + purchaseItems[indexPath.item], for: .normal)
        } else {
            cell.purchaseBtn.setTitle(purchaseItems[indexPath.item], for: .normal)
        }
        cell.itemLbl.text = "$" + listOfPurchase[indexPath.item]
        return cell
    }
    
    
}


extension ProfileViewController: GADBannerViewDelegate{

    // Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
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

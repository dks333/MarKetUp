//
//  SupportViewController.swift
//  MarKetUp
//
//  Created by Sam Ding on 10/17/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import UIKit
import Charts
import GoogleMobileAds

class AccountViewController: SubProfileViewController {

    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var stockValueLbl: UILabel!
    @IBOutlet weak var cashLbl: UILabel!
    @IBOutlet weak var totalValueLbl: UILabel!
    @IBOutlet weak var chargedCashLbl: UILabel!
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    var cashDataEntry = PieChartDataEntry(value: 0)
    var valueDataEntry = PieChartDataEntry(value: 0)
    
    var portfolioLoadsDataEntries = [PieChartDataEntry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !UserDefaults.standard.bool(forKey: "RemovedAds") {
            
        } else {
            bannerView.isHidden = true
        }
        super.viewWillAppear(animated)
    }
    
    private func setUpView(){
        
        loadBannerView()
        
        pieChartView.chartDescription?.text = ""
        pieChartView.holeColor = .black
        
        
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2

        cashDataEntry.value = Double(numberFormatter.string(from: NSNumber(value: User.shared.cashes))!)!
        cashLbl.text = "$" + numberFormatter.string(from: NSNumber(value: User.shared.cashes))!
        cashDataEntry.label = ""

        valueDataEntry.value = Double(numberFormatter.string(from: NSNumber(value: User.shared.values))!)!
        stockValueLbl.text = "$" + numberFormatter.string(from: NSNumber(value: User.shared.values))!
        valueDataEntry.label = ""
        
        portfolioLoadsDataEntries = [cashDataEntry, valueDataEntry]
        pieChartView.highlightPerTapEnabled = false
        pieChartView.drawEntryLabelsEnabled = false
        pieChartView.drawSlicesUnderHoleEnabled = true
        pieChartView.legend.enabled = false
        pieChartView.drawCenterTextEnabled = false
        
        pieChartView.holeRadiusPercent = 0.95
        
        updateChartData()
        
        totalValueLbl.text = "$" + numberFormatter.string(from: NSNumber(value: User.shared.getTotalValues()))!
        numberFormatter.minimumFractionDigits = 0
        chargedCashLbl.text = "$" + numberFormatter.string(from: NSNumber(value: User.shared.chargedCash))!
    }
    

    func updateChartData() {
           
        let chartDataSet = PieChartDataSet(entries: portfolioLoadsDataEntries, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        
        chartDataSet.drawValuesEnabled = false
        
        chartDataSet.sliceSpace = 10
        chartDataSet.valueTextColor = .black
        
        
        let colors = [UIColor.lightGreen, UIColor.lightGreen]
        chartDataSet.colors = colors
           
        pieChartView.data = chartData
           
    }
    
    private func loadBannerView(){
           // Set up Google Ad Banner View
           bannerView.adUnitID = AdUnit.TestID  //TODO: Change this Unit Ad back when got to production
           bannerView.rootViewController = self
           bannerView.load(GADRequest())
    }
    

    

}

// Google Banner View
extension AccountViewController: GADBannerViewDelegate{

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


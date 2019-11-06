//
//  DetailStockHistoryViewController.swift
//  MarKetUp
//
//  Created by Sam Ding on 11/2/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import UIKit

class DetailStockHistoryViewController: SubProfileViewController {

    var currentStockHistory : StockHistory?
    @IBOutlet weak var closeBtn: UIButton!
    

    @IBOutlet var stackView: [UIStackView]!
    @IBOutlet weak var symbolLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var sharesLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var totalValueLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
    }
    
    private func setUpView(){
        symbolLbl.text = currentStockHistory?.symbol
        typeLbl.text = currentStockHistory?.type
        dateLbl.text = currentStockHistory?.date
        timeLbl.text = currentStockHistory?.time
        sharesLbl.text = "\(String(describing: currentStockHistory!.shares))"
        priceLbl.text = "$\(String(describing: currentStockHistory!.price))"
        totalValueLbl.text = "$\(currentStockHistory!.price * Float(currentStockHistory!.shares))"
        
        closeBtn.layer.cornerRadius = 5
        
        for view in stackView{
            view.addBottomBorder(with: .MedianGray, andWidth: 1)
        }

    }
    
    @IBAction func closeVC(_ sender: Any) {
        self.dismiss(animated: true)
    }
    


}

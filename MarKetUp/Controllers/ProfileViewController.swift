//
//  ProfileViewController.swift
//  MarKetUp
//
//  Created by Sam Ding on 9/16/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class ProfileViewController: UIViewController{
    
    var user: User!
    
    @IBOutlet weak var purchaseCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        setupView()
    }
    
    private func setupView(){
        
    }
    
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "purchaseCell", for: indexPath) as! PurchaseCollectionViewCell
        
        return cell
    }
    
    
}

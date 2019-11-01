//
//  IAPService.swift
//  MarKetUp
//
//  Created by Sam Ding on 10/24/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import Foundation
import StoreKit

class IAPService: NSObject {

    
    private override init() {
        
    }
    
    static let shared = IAPService()
    let paymentQueue = SKPaymentQueue.default()
    
    var products = [SKProduct]()
    
    func getProducts() {
        let products: Set = [IAPProducts.RemoveAds.rawValue,
                             IAPProducts.LevelOneCredit.rawValue,
                             IAPProducts.LevelTwoCredit.rawValue,
                             IAPProducts.LevelThreeCredit.rawValue,
                             IAPProducts.LevelFourCredit.rawValue]
        
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        paymentQueue.add(self)
    }
    
    // Makeing Purchase
    func purchase(product: IAPProducts){
        guard let productToPurchase = products.filter({ $0.productIdentifier == product.rawValue}).first else {return}
        let payment = SKPayment(product: productToPurchase)
        paymentQueue.add(payment)
    }
    
    func restorePurchases(){
        print("restore purchases")
        paymentQueue.restoreCompletedTransactions()
    }
    
}


extension IAPService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        for product in response.products {
            //print(product.localizedTitle)
        }
    }
    
    
}

extension IAPService: SKPaymentTransactionObserver{
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print(transaction.transactionState.status(), transaction.payment.productIdentifier)
            switch transaction.transactionState {
            case .failed:
              fail(transaction: transaction)
              queue.finishTransaction(transaction)
              break
            case .restored:
                queue.finishTransaction(transaction)
              
              break
            case .deferred:
                queue.finishTransaction(transaction)
              break
            case .purchasing:
                
                break
            case .purchased:
                addCreditToAccount(productId: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                break
            default: queue.finishTransaction(transaction)
            }
        }
    }
    
    private func fail(transaction: SKPaymentTransaction) {
      print("------fail-------")
      if let transactionError = transaction.error as NSError?,
        let localizedDescription = transaction.error?.localizedDescription,
          transactionError.code != SKError.paymentCancelled.rawValue {
          print("Transaction Error: \(localizedDescription)")
        }

      SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    
    /**
     Ads: 2.99
     5000: 0.99
     20000: 1.99
     300000: 9.99
     3000000: 49.99
     */

    private func addCreditToAccount(productId: String){
        if productId == IAPProducts.LevelOneCredit.rawValue {
            User.shared.cashes += 5000
        } else if productId == IAPProducts.LevelTwoCredit.rawValue {
            User.shared.cashes += 20000
        } else if productId == IAPProducts.LevelThreeCredit.rawValue {
            User.shared.cashes += 300000
        } else if productId == IAPProducts.LevelFourCredit.rawValue {
            User.shared.cashes += 3000000
        } else if productId == IAPProducts.RemoveAds.rawValue {
            
        }

    }
    
}

extension SKPaymentTransactionState{
    func status() -> String{
        switch self {
        case .deferred: return ("deferred")
        case .failed: return ("failed")
        case .purchased: return ("purchased")
        case .purchasing: return ("purchasing")
        case .restored: return ("restored")
        @unknown default:
            fatalError()
        }
    }
}

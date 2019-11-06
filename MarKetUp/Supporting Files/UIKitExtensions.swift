//
//  UIKitExtensions.swift
//  MarKetUp
//
//  Created by Sam Ding on 9/16/19.
//  Copyright © 2019 Kaishan Ding. All rights reserved.
//

import Foundation
import UIKit

var vSpinner = UIView()

extension UIViewController {
    
    func setTabBarVisible(visible: Bool, animated: Bool) {
        //* This cannot be called before viewDidLayoutSubviews(), because the frame is not set before this time
        // bail if the current state matches the desired state
        if (isTabBarVisible == visible) { return }
        
        // get a frame calculation ready
        let frame = self.tabBarController?.tabBar.frame
        let height = frame?.size.height
        let offsetY = (visible ? -height! : height)
        
        // zero duration means no animation
        let duration: TimeInterval = (animated ? 0.3 : 0.0)
        
        //  animate the tabBar
        if frame != nil {
            UIView.animate(withDuration: duration) {
                self.tabBarController?.tabBar.frame = frame!.offsetBy(dx: 0, dy: offsetY!)
                return
            }
        }
    }
    
    var isTabBarVisible: Bool {
        return (self.tabBarController?.tabBar.frame.origin.y ?? 0) < self.view.frame.maxY
    }
    
    // Show Loading Spinner
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = .clear
        let ai = UIActivityIndicatorView.init(style: .white)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner.removeFromSuperview()
            vSpinner = UIView()
        }
    }
    
}


extension UIView{
    // add drop shadow effect
    func addDropShadow(scale: Bool = true, cornerRadius: CGFloat ) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        layer.shadowColor = UIColor.white.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = .zero
        layer.shadowRadius = 1.5
        
        //layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    
    // animate UIView expand from bottom to top and vice versa
    
    func slideUpShow(_ duration: CGFloat){
        UIView.animate(withDuration: TimeInterval(duration), delay: 0, options: [.curveEaseOut],
                       animations: {
                        self.center.y -= self.bounds.height
                        self.layoutIfNeeded()
        }, completion: nil)
        //self.isHidden = false
    }
    func slideDownHide(_ duration: CGFloat){
        UIView.animate(withDuration: TimeInterval(duration), delay: 0, options: [.curveEaseOut],
                       animations: {
                        self.center.y += self.bounds.height
                        self.layoutIfNeeded()
                        
        },  completion: {(_ completed: Bool) -> Void in
            //self.isHidden = true
        })
    }
    
    func addBottomBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        border.frame = CGRect(x: 0, y: frame.size.height - borderWidth, width: frame.size.width, height: borderWidth)
        addSubview(border)
    }
    
}

extension UIColor{
    static let custumGreen = UIColor(red: 0.25, green: 0.75, blue: 0.3, alpha: 1)
    static let customRed = UIColor(red: 1, green: 0.03, blue: 0, alpha: 1)
    static let GrayBlack = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    static let lightGreen = UIColor(red: 0.365, green: 0.961, blue: 0.455, alpha: 1)
    static let MedianGray = UIColor(red: 0.32, green: 0.32, blue: 0.32, alpha: 1)
}

extension UIButton {
    func setTitleWithOutAnimation(title: String?) {
        UIView.setAnimationsEnabled(false)

        setTitle(title, for: .normal)

        layoutIfNeeded()
        UIView.setAnimationsEnabled(true)
    }
}

extension NSLayoutConstraint {
    func setMultiplier(_ multiplier:CGFloat) -> NSLayoutConstraint {

         NSLayoutConstraint.deactivate([self])

         let newConstraint = NSLayoutConstraint(
             item: firstItem!,
             attribute: firstAttribute,
             relatedBy: relation,
             toItem: secondItem,
             attribute: secondAttribute,
             multiplier: multiplier,
             constant: constant)

         newConstraint.priority = priority
         newConstraint.shouldBeArchived = shouldBeArchived
         newConstraint.identifier = identifier

         NSLayoutConstraint.activate([newConstraint])
         return newConstraint
     }
}

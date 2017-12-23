//
//  NavigationController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/13.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import Cartography
import UIKit

class BlueNavigationController: UINavigationController {
    
    // MARK: Property
    
    let navigationBarGradientLayer = CAGradientLayer()
    
    private let navigationBarGradientView = UIView()
    
    // MARK: Appearance
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .lightContent
        
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpGradientNavigationBar()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        navigationBarGradientLayer.frame = navigationBarGradientView.bounds
        
    }
    
    // MARK: Set Up
    
    func setUpGradientNavigationBar() {
        
        // Make navigation bar transparent completely.
        navigationBar.setBackgroundImage(
            UIImage(),
            for: .default
        )
        
        navigationBar.shadowImage = UIImage()
        
        navigationBar.isTranslucent = true
        
        navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor(red: 80/255.0, green: 227/255.0, blue: 194/255.0, alpha: 1),
            NSAttributedStringKey.font: UIFont(name: "IowanOldStyle-Bold", size: 22)!
        ]
        
        // Prepare gradient navigation bar view
        
        view.insertSubview(
            navigationBarGradientView,
            belowSubview: navigationBar
        )
        
        constrain(
            navigationBarGradientView,
            navigationBar,
            block: { navigationBarGradientView, navigationBar in
                
                let superview = navigationBarGradientView.superview!
                
                navigationBarGradientView.leading == superview.leading
                
                navigationBarGradientView.top == superview.top
                
                navigationBarGradientView.trailing == superview.trailing
                
                navigationBarGradientView.bottom == navigationBar.bottom
                
        }
        )
        
        // Prepare gradient layer
        
        let gradientLayer = navigationBarGradientLayer
        
        gradientLayer.colors = [
            UIColor(red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 1.0).cgColor,
            UIColor(red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 1.0).cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        navigationBarGradientView.layer.insertSublayer(
            gradientLayer,
            at: 0
        )
        
    }
    
}

//
//  NavigationController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/13.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import Cartography
import UIKit

class GradientNavigationController: UINavigationController {
    
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
            UIColor(red: 3.0 / 255.0, green: 63.0 / 255.0, blue: 122.0 / 255.0, alpha: 1.0).cgColor,
            UIColor(red: 4.0 / 255.0, green: 107.0 / 255.0, blue: 149.0 / 255.0, alpha: 1.0).cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        navigationBarGradientView.layer.insertSublayer(
            gradientLayer,
            at: 0
        )
        
    }
    
}

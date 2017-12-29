//
//  UIWindowExtensions.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/29.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import Foundation

extension UIWindow {
    
    typealias UpdateRootCompletion = (Bool) -> Void
    
    typealias UpdateRootAnimation = (_ from: UIViewController?, _ to: UIViewController, _ completion: UpdateRootCompletion?) -> Void
    
    func updateRoot(
        to newViewController: UIViewController,
        animation: UpdateRootAnimation,
        completion: UpdateRootCompletion?
        ) {
        
        let fromViewController = rootViewController
        
        let toViewController = newViewController
        
        rootViewController = toViewController
        
        animation(
            fromViewController,
            toViewController,
            completion
        )
        
    }
    
}

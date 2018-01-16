//
//  FadeInOutTransition.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/29.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import Foundation

typealias CrossDissolveCompletion = (Bool) -> Void

// swiftlint:disable variable_name
func crossDissolve(from: UIViewController?, to: UIViewController, completion: CrossDissolveCompletion?) {
    // swiftlint:enable variable_name

    guard
        let from = from
        else {

            completion?(true)

            return

    }

    let fromView = from.view!

    let toView = to.view!

    toView.addSubview(fromView)

    UIView.animate(
        withDuration: 1.0,
        animations: {

            fromView.layer.opacity = 0.0

    },
        completion: { isComplete in

            fromView.removeFromSuperview()

            completion?(isComplete)

    }
    )

}

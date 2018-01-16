//
//  LoadingIndicator.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/19.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import Foundation
import NVActivityIndicatorView

class LoadingIndicator {

    var activityData = ActivityData(type: .ballPulseSync)

    func start() {
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
    }

    func stop() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
}

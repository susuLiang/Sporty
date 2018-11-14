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

        navigationBar.tintColor = UIColor.white

        navigationBar.shadowImage = UIImage()

        navigationBar.isTranslucent = true

        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "IowanOldStyle-Bold", size: 22)!
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
            myBlue.cgColor,
            mySkyBlue.cgColor
        ]

        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)

        gradientLayer.endPoint = CGPoint(x: 0, y: 1.0)

        navigationBarGradientView.layer.insertSublayer(
            gradientLayer,
            at: 0
        )

    }

}

//
//  OrdersController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/20.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Firebase
import Crashlytics

class MyActivitiesController: ButtonBarPagerTabStripViewController {

    @IBOutlet weak var shadowView: UIView!

    let graySpotifyColor = UIColor(red: 21/255.0, green: 21/255.0, blue: 24/255.0, alpha: 1.0)
    let darkGraySpotifyColor = UIColor(red: 19/255.0, green: 20/255.0, blue: 20/255.0, alpha: 1.0)

    override func viewDidLoad() {
        self.navigationController?.navigationBar.isTranslucent = false

        // change selected bar color
        settings.style.buttonBarBackgroundColor = myBlack
        settings.style.buttonBarItemBackgroundColor = myBlack
        settings.style.selectedBarBackgroundColor = myPurple
        settings.style.buttonBarItemFont = UIFont(name: "ArialHebrew-Bold", size:16) ?? UIFont.systemFont(ofSize: 16)
        settings.style.selectedBarHeight = 3.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true

        settings.style.buttonBarLeftContentInset = 20
        settings.style.buttonBarRightContentInset = 20

        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor(red: 138/255.0, green: 138/255.0, blue: 144/255.0, alpha: 1.0)
            newCell?.label.textColor = .white
        }
        super.viewDidLoad()
        setNavigationItem()
    }

    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let matchesVC = MyMatchesController(itemInfo: IndicatorInfo(title: NSLocalizedString("Join", comment: "")))
        let postsVC = MyPostsController(itemInfo: IndicatorInfo(title: NSLocalizedString("MyPosts", comment: "")))
        return [matchesVC, postsVC]
    }

    // MARK: - Actions
    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    func setNavigationItem() {
        navigationItem.title = NSLocalizedString("My Activities", comment: "")
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "MyriadApple-Semibold", size: 24),
                                                                        NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = myBlue
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "icon-left")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "icon-left")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: self, action: nil)
        navigationController?.navigationBar.tintColor = .white
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        settings.style.buttonBarHeight = 0
    }

}

//
//  ActivityController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/14.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit

class ActivityController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var mapPlacedView: UIView!
    @IBOutlet weak var feeLabel: UILabel!
    
    var selectedActivity: Activity?  {
        
        didSet {
            
            nameLabel.text = selectedActivity?.id
            authorLabel.text = selectedActivity?.author
            typeLabel.text = selectedActivity?.type.rawValue
            levelLabel.text = selectedActivity?.level.rawValue
            timeLabel.text = selectedActivity?.time
            placeLabel.text = selectedActivity?.place
            numberLabel.text = "\(selectedActivity?.number) / \(selectedActivity?.allNumber)"
            feeLabel.text = "\(selectedActivity?.fee)"
            
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

//
//  UserSettingCell.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/19.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit

class UserSettingCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            nameLabel.backgroundColor = isSelected ? UIColor.yellow : UIColor.clear
        }
    }

}

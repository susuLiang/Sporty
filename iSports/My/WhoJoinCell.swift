//
//  WhoJoinCell.swift
//  iSports
//
//  Created by Susu Liang on 2018/1/2.
//  Copyright © 2018年 Susu Liang. All rights reserved.
//

import UIKit

class WhoJoinCell: UICollectionViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        userPhoto.layer.cornerRadius = userPhoto.frame.width / 2
        userPhoto.clipsToBounds = true

        backView.layer.cornerRadius = 20
        backView.layer.shadowRadius = 5
        backView.layer.shadowOffset = CGSize(width: 2, height: 5)
        backView.layer.shadowOpacity = 0.7
    }

}

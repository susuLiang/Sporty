//
//  TypeSettingCell.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/26.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit

class TypeSettingCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        typeImage.layer.cornerRadius = 20
        typeImage.clipsToBounds = true
        backView.alpha = 0.7
        backgroundColor = myBlack

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

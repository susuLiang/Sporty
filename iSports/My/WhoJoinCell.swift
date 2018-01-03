//
//  WhoJoinCell.swift
//  iSports
//
//  Created by Susu Liang on 2018/1/2.
//  Copyright © 2018年 Susu Liang. All rights reserved.
//

import UIKit

class WhoJoinCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        userPhoto.layer.cornerRadius = userPhoto.frame.width / 2
        userPhoto.clipsToBounds = true
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

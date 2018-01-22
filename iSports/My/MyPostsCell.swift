//
//  MyPostsCell.swift
//  iSports
//
//  Created by Susu Liang on 2018/1/3.
//  Copyright © 2018年 Susu Liang. All rights reserved.
//

import UIKit

class MyPostsCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var seeWhoButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var messageButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.cornerRadius = 30
        backView.layer.shadowRadius = 5
        backView.layer.shadowOffset = CGSize(width: -5, height: 5)
        backView.layer.shadowOpacity = 0.7

        let editIcon = UIImage(named: "icon-edit")?.withRenderingMode(.alwaysTemplate)
        editButton.setImage(editIcon, for: .normal)
        editButton.tintColor = myRed

        let seeWhoIcon = UIImage(named: "icon-group")?.withRenderingMode(.alwaysTemplate)
        seeWhoButton.setImage(seeWhoIcon, for: .normal)
        seeWhoButton.tintColor = UIColor(red: 249/255, green: 69/255, blue: 46/255, alpha: 1)

        let messageIcon = UIImage(named: "icon-chat")
        messageButton.setImage(messageIcon, for: .normal)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }

}

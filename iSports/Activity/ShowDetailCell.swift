//
//  ShowDetailCell.swift
//  iSports
//
//  Created by Susu Liang on 2018/1/5.
//  Copyright © 2018年 Susu Liang. All rights reserved.
//

import UIKit
import LGButton

class ShowDetailCell: UITableViewCell {

    @IBOutlet weak var activityTitleLabel: UILabel!
    @IBOutlet weak var activityDetailLabel: UILabel!
    @IBOutlet weak var backView: LGButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 204/255, alpha: 1)

//        backView.isHidden = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setCell(title: String, detail: Any) {
        activityTitleLabel.text = "\(title):"
        activityDetailLabel.text = "\(detail)"

    }

}

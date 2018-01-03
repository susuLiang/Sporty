//
//  TableViewCell.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/25.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit

class MapSearchCell: UITableViewCell {

    @IBOutlet weak var typeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        typeLabel.backgroundColor = myRed
        typeLabel.tintColor = .white
        typeLabel.layer.masksToBounds = true
        typeLabel.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: false)

    }

}

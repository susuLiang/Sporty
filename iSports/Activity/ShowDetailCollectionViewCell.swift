//
//  ShowDetailCollectionViewCell.swift
//  iSports
//
//  Created by Susu Liang on 2018/1/11.
//  Copyright © 2018年 Susu Liang. All rights reserved.
//

import UIKit

class ShowDetailCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleView.layer.cornerRadius = 10
        titleView.layer.borderWidth = 1
        titleView.layer.shadowRadius = 1

        descriptionView.layer.cornerRadius = 10
        descriptionView.layer.shadowRadius = 3
        descriptionView.layer.shadowOffset = CGSize(width: 0, height: 0)
        descriptionView.layer.shadowOpacity = 1

    }

    func setCell(title: String, detail: Any) {
        titleLabel.text = "\(title)"
        descriptionLabel.text = "\(detail)"

    }

}

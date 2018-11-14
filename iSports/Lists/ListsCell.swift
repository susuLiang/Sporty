//
//  ListsCell.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/13.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit

class ListsCell: UITableViewCell {

    @IBOutlet weak var buttonStatusLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var imagePlaced: UIImageView!
    @IBOutlet weak var levelImage: UIImageView!
    @IBOutlet weak var recommendImage: UIImageView!
    @IBOutlet weak var backView: UIView!

    var joinIcon = UIImage(named: "icon-join")?.withRenderingMode(.alwaysTemplate)

    override func awakeFromNib() {
        super.awakeFromNib()

        setFont()

        backView.layer.shadowColor = UIColor.gray.cgColor
        backView.layer.shadowRadius = 6
        backView.layer.shadowOpacity = 1
        backView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setFont() {

        // imagePlaced
        imagePlaced.frame.size = CGSize(width: 75, height: 75)
        imagePlaced.contentMode = .scaleToFill

        // titleLabel
        titleLabel.font = UIFont(name: "MyriadApple-Semibold", size: 20)

        // timeLabel
        timeLabel.font = UIFont(name: "MyriadApple-Semibold", size: 14)
        timeLabel.tintColor = .white

        //placeLabel
        placeLabel.font = UIFont(name: "MyriadApple-Semibold", size: 14)
        placeLabel.tintColor = .white

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        recommendImage?.image = nil
        numLabel.textColor = myIndigo
    }

    func setCell(_ activity: Activity) {
        titleLabel.text = activity.name
        timeLabel.text = activity.time
        placeLabel.text = activity.place.placeName
        numLabel.text = "\(activity.number) / \(activity.allNumber)"
        imagePlaced.image = (Sportstype(rawValue: activity.type) ?? Sportstype.baseball).image

        var thisLevel: String = ""
        switch activity.level {
        case "A": thisLevel = "labelA"
        case "B": thisLevel = "labelB"
        case "C": thisLevel = "labelC"
        case "D": thisLevel = "labelD"
        default: break
        }
        levelImage.image = UIImage(named: thisLevel)
    }

    func setJoinButtonStatus(isEnable: Bool, tintColor: UIColor, labelTextColor: UIColor, statusText: String) {
        joinButton.isEnabled = isEnable
        joinButton.setImage(joinIcon, for: .normal)
        joinButton.tintColor = tintColor
        numLabel.textColor = labelTextColor
        buttonStatusLabel.text = statusText
        buttonStatusLabel.textColor = labelTextColor
    }

}

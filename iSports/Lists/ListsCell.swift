//
//  ListsCell.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/13.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit

class ListsCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var imagePlaced: UIImageView!
    @IBOutlet weak var levelImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = myBlue
        
        setFont()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setFont() {
        
        // imagePlaced
        imagePlaced.frame.size = CGSize(width: 75, height: 75)
        imagePlaced.contentMode = .scaleToFill
        
        // titleLabel
        titleLabel.font = UIFont(name: "ArialHebrew-Bold", size: 20)
        
        // timeLabel
        timeLabel.font = UIFont(name: "ArialHebrew-Bold", size: 14)
        timeLabel.tintColor = myWhite
        
        //placeLabel
        placeLabel.font = UIFont(name: "ArialHebrew-Bold", size: 14)
        placeLabel.tintColor = myWhite
        
        //numLabel
        numLabel.tintColor = myWhite
        
    }

}

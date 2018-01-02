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
    @IBOutlet weak var recommendImage: UIImageView!
    @IBOutlet weak var backView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setFont()
        
        backView.layer.shadowColor = UIColor.gray.cgColor
        backView.layer.shadowRadius = 10
        backView.layer.shadowOpacity = 1
        backView.layer.shadowOffset = CGSize(width: 10, height: 10)
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
        titleLabel.font = UIFont(name: "ArialHebrew-Bold", size: 20)
        
        // timeLabel
        timeLabel.font = UIFont(name: "ArialHebrew-Bold", size: 14)
        timeLabel.tintColor = .white
        
        //placeLabel
        placeLabel.font = UIFont(name: "ArialHebrew-Bold", size: 14)
        placeLabel.tintColor = .white
        
        //numLabel
        numLabel.tintColor = .white
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        recommendImage?.image = nil
    }
}

//
//  ActivityButtonTableViewCell.swift
//  iSports
//
//  Created by Shu Wei Liang on 2018/11/13.
//  Copyright © 2018 Susu Liang. All rights reserved.
//

import UIKit
import LGButton

protocol ActivityButtonDelegate: class {
    func tapButton()
}

class ActivityButtonTableViewCell: UITableViewCell {
    
    weak var delegate: ActivityButtonDelegate?

    @IBAction func tapButton(_ sender: LGButton) {
        delegate?.tapButton()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

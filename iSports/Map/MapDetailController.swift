//
//  MapDetailController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/25.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit

class MapDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBAction func backButton(_ sender: Any) {
        self.view.removeFromSuperview()
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var placeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListsCell
//        let result = results[indexPath.row]
//        cell.titleLabel.text = result.name
//        cell.timeLabel.text = result.time
//        cell.levelLabel.text = result.level.rawValue
//        cell.placeLabel.text = result.place.placeName
//        cell.numLabel.text = "\(result.number) / \(result.allNumber)"
//        var isMyMatch = false
//        if result.authorUid != uid {
//            for myMatch in myMatches where myMatch.id == result.id {
//                isMyMatch = true
//            }
//            if result.number < result.allNumber && !isMyMatch {
//                cell.joinButton.isEnabled = true
//                cell.joinButton.tintColor = UIColor.yellow
//                cell.joinButton.addTarget(self, action: #selector(self.join), for: .touchUpInside)
//            } else {
//                cell.joinButton.isEnabled = false
//                cell.joinButton.tintColor = UIColor.gray
//            }
//
//        } else {
//            cell.joinButton.isEnabled = false
//            cell.joinButton.backgroundColor = UIColor.clear
//            cell.joinButton.tintColor = UIColor.clear
//        }
//
//        switch result.type {
//        case "羽球": cell.imagePlaced.image = UIImage(named: "badminton")!
//        case "棒球": cell.imagePlaced.image = UIImage(named: "baseball")!
//        case "籃球": cell.imagePlaced.image = UIImage(named: "basketball")!
//        case "排球": cell.imagePlaced.image = UIImage(named: "volleyball")!
//        case "網球": cell.imagePlaced.image = UIImage(named: "tennis")!
//        case "足球": cell.imagePlaced.image = UIImage(named: "soccer")!
//        default:
//            return cell
//        }
        return cell
    }

}

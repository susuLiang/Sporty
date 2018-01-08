//
//  MyMatchController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/20.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Firebase
import KeychainSwift
import SCLAlertView
import TimelineTableViewCell

class MyMatchesController: UITableViewController, IndicatorInfoProvider {

    init(style: UITableViewStyle, itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var itemInfo = IndicatorInfo(title: "Join")
    let userUid = KeychainSwift().get("uid")
    var myMatches = [String: Activity]()
    var keyUid = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableCell()

        view.backgroundColor = .white

        FirebaseProvider.shared.getPosts(childKind: "joinId", completion: { (posts, error) in
            if error == nil {
                self.myMatches = posts!
                self.myMatches.values.sorted(by: { $0.postedTime > $1.postedTime })
                self.tableView.reloadData()
            }
        })
    }

    func setupTableCell() {
        tableView.separatorStyle = .none
        let bundle = Bundle(for: TimelineTableViewCell.self)
        let nibUrl = bundle.url(forResource: "TimelineTableViewCell", withExtension: "bundle")
        let timelineTableViewCellNib = UINib(nibName: "TimelineTableViewCell",
                                             bundle: Bundle(url: nibUrl!)!)
        tableView.register(timelineTableViewCellNib, forCellReuseIdentifier: "TimelineTableViewCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case section:
            let timeMatchs = self.myMatches.values.filter({ (myMatch) -> Bool in
                let matchIndex = myMatch.time.index(myMatch.time.startIndex, offsetBy: 3)
                let matchWeek = myMatch.time[..<matchIndex]

                return matchWeek == time[section]
            })
            return timeMatchs.count
        default:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineTableViewCell", for: indexPath) as? TimelineTableViewCell
            else { fatalError() }
        switch indexPath.section {
        case indexPath.section:
            var timeMatchs = self.myMatches.values.filter({ (myMatch) -> Bool in
                let matchIndex = myMatch.time.index(myMatch.time.startIndex, offsetBy: 3)
                let matchWeek = myMatch.time[..<matchIndex]
                return matchWeek == time[indexPath.section]
            })

            timeMatchs.sort(by: {$0.time < $1.time})
            
            
            cell.titleLabel.text = timeMatchs[indexPath.row].time

            cell.placeLabel.text = timeMatchs[indexPath.row].place.placeName
            cell.newTitleLabel.text = timeMatchs[indexPath.row].name
            let quitIcon = UIImage(named: "icon-quit")?.withRenderingMode(.alwaysTemplate)
            cell.cancelButton.setImage(quitIcon, for: .normal)
            cell.cancelButton.tintColor = .red
            cell.cancelButton.addTarget(self, action: #selector(deleteIt), for: .touchUpInside)
            switch timeMatchs[indexPath.row].type {
            case "羽球": cell.thumbnailImageView.image = UIImage(named: "badminton")!
            case "棒球": cell.thumbnailImageView.image = UIImage(named: "baseball")!
            case "籃球": cell.thumbnailImageView.image = UIImage(named: "basketball")!
            case "排球": cell.thumbnailImageView.image = UIImage(named: "volleyball")!
            case "網球": cell.thumbnailImageView.image = UIImage(named: "tennis")!
            case "足球": cell.thumbnailImageView.image = UIImage(named: "soccer")!
            default:
                return cell
            }
        default:
            break
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let activityView = UINib.load(nibName: "ShowDetailController") as? ShowDetailController else {
            print("ShowDetailController invalid")
            return
        }

        let thatWeek = self.myMatches.values.filter({ (myMatch) -> Bool in
            let matchIndex = myMatch.time.index(myMatch.time.startIndex, offsetBy: 3)
            let matchWeek = myMatch.time[..<matchIndex]
            return matchWeek == time[indexPath.section]
        })

        activityView.selectedActivity = thatWeek[indexPath.row]
        navigationController?.pushViewController(activityView, animated: true)
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

    @objc func deleteIt(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? TimelineTableViewCell,
            let indexPath = tableView.indexPath(for: cell) else {
                print("It's not the right cell.")
                return
        }
        let thatWeek = self.myMatches.values.filter({ (myMatch) -> Bool in
            let matchIndex = myMatch.time.index(myMatch.time.startIndex, offsetBy: 3)
            let matchWeek = myMatch.time[..<matchIndex]
            return matchWeek == time[indexPath.section]
        })
        
        let keys = self.myMatches.keys
        var uid = ""
        
        for key in keys where self.myMatches[key]?.id == thatWeek[indexPath.row].id {
            uid = key
        }

        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton(NSLocalizedString("SURE", comment: ""), action: {
            let ref = Database.database().reference()
            let activityUid = thatWeek[indexPath.row].id
            let newValue = thatWeek[indexPath.row].number - 1
            ref.child("user_joinId").child(uid).removeValue()
            ref.child("activities").child(activityUid).updateChildValues(["number": newValue])
        })
        alertView.addButton(NSLocalizedString("NO", comment: "")) {}
        alertView.showWarning(NSLocalizedString("Sure to quit ?", comment: ""), subTitle: "")
    }

}

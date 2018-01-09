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

class MyMatchesController: UIViewController, IndicatorInfoProvider, UITableViewDelegate, UITableViewDataSource {

    init(itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var itemInfo = IndicatorInfo(title: "Join")
    let userUid = KeychainSwift().get("uid")
    var myMatches = [String: Activity]()
    var keyUid = [String]()
    var timeMatchArray: [[Activity]] = []
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupTableView()
        setupTableCell()
        getFilterArrayByTime()
        
        navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-cancel"), style: .plain, target: self, action: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setupTableView() {
        tableView.frame = view.frame
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    }

    func setupTableCell() {
        tableView.separatorStyle = .none
        let bundle = Bundle(for: TimelineTableViewCell.self)
        let nibUrl = bundle.url(forResource: "TimelineTableViewCell", withExtension: "bundle")
        let timelineTableViewCellNib = UINib(nibName: "TimelineTableViewCell",
                                             bundle: Bundle(url: nibUrl!)!)
        tableView.register(timelineTableViewCellNib, forCellReuseIdentifier: "TimelineTableViewCell")
    }
    
    func getFilterArrayByTime() {
        FirebaseProvider.shared.getPosts(childKind: "joinId", completion: { (posts, error) in
            if error == nil {
                self.myMatches = posts!
                
                self.timeMatchArray = []
                for i in 0...time.count - 1 {
                    let timeMatchs = self.myMatches.values.filter({ (myMatch) -> Bool in
                        let matchIndex = myMatch.time.index(myMatch.time.startIndex, offsetBy: 3)
                        let matchWeek = myMatch.time[..<matchIndex]
                        return matchWeek == time[i]
                    })
                    self.timeMatchArray.append(timeMatchs)
                }
                
                self.myMatches.values.sorted(by: { $0.postedTime > $1.postedTime })
                self.tableView.reloadData()
            }
        })
    }

    @objc func showMessages(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? TimelineTableViewCell,
            let indexPath = tableView.indexPath(for: cell) else {
                print("It's not the right cell.")
                return
        }

        let thatWeek = timeMatchArray[indexPath.section]

        // swiftlint:disable force_cast
        let messagesView = UINib.load(nibName: "MessagesViewController") as! MessagesViewController
        // swiftlint:enable force_cast

        messagesView.thisActivityUid = thatWeek[indexPath.row].id
        messagesView.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - (self.tabBarController?.tabBar.frame.height)! * 2 - (self.navigationController?.navigationBar.frame.height)!)
        
        self.addChildViewController(messagesView)
        self.view.addSubview(messagesView.view)
        messagesView.didMove(toParentViewController: self)
    }

    @objc func quitIt(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? TimelineTableViewCell,
            let indexPath = tableView.indexPath(for: cell) else {
                print("It's not the right cell.")
                return
        }

        let thatWeek = timeMatchArray[indexPath.section]

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

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if timeMatchArray.count > 0 {
            switch section {
            case section:
                let thatWeek = timeMatchArray[section]
                return thatWeek.count
            default:
                return 1
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineTableViewCell", for: indexPath) as? TimelineTableViewCell
            else { fatalError() }
        switch indexPath.section {
        case indexPath.section:
            let timeMatchs = timeMatchArray[indexPath.section]

            timeMatchs.sorted(by: {$0.time < $1.time})

            cell.titleLabel.text = timeMatchs[indexPath.row].time

            cell.placeLabel.text = timeMatchs[indexPath.row].place.placeName
            cell.newTitleLabel.text = timeMatchs[indexPath.row].name
            let quitIcon = UIImage(named: "icon-quit")?.withRenderingMode(.alwaysTemplate)
            cell.cancelButton.setImage(quitIcon, for: .normal)
            cell.cancelButton.tintColor = .red
            cell.cancelButton.addTarget(self, action: #selector(quitIt), for: .touchUpInside)
            cell.chatButton.setImage(UIImage(named: "icon-chat"), for: .normal)
            cell.chatButton.addTarget(self, action: #selector(showMessages), for: .touchUpInside)
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let activityView = UINib.load(nibName: "ShowDetailController") as? ShowDetailController else {
            print("ShowDetailController invalid")
            return
        }

        let thatWeek = timeMatchArray[indexPath.section]

        activityView.selectedActivity = thatWeek[indexPath.row]
        navigationController?.pushViewController(activityView, animated: true)
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

}

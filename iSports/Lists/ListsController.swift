//
//  TableViewController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/13.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase
import KeychainSwift
import WCLShineButton
import SCLAlertView
import Crashlytics
import JTMaterialTransition

class ListsController: UIViewController {
    // Property
    var isShowed = false

    var keyChain = KeychainSwift()

    var results = [Activity]()

    var selectedPreference: Preference? {
        didSet {
            search(selected: selectedPreference!)
        }
    }

    var userSetting: UserSetting? {
        didSet {
            if let name = userSetting?.name {
                keyChain.set(name, forKey: "name")
            }
            self.tableView.reloadData()
        }
    }

    var uid = Auth.auth().currentUser?.uid

    var ref = Database.database().reference()
    
    var transition: JTMaterialTransition?

    var myMatches = [Activity]()
    var tableView = UITableView()
    var thisSearchView: SearchViewController?

    lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(showAddView), for: .touchUpInside)
        button.setImage(UIImage(named: "icon-add"), for: .normal)
        button.tintColor = myGreen
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.shadowRadius = 10
        return button
    }()

    override func viewDidLoad() {

        super.viewDidLoad()

        view.backgroundColor = .clear

        tableView.delegate = self

        tableView.dataSource = self

        tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        tableView.separatorStyle = .none

        self.view.addSubview(tableView)

        self.view.addSubview(addButton)

        setUpAddButton()

        setupTableCell()

        setNavigation()

        fetch()

        getPosts()

        getUserProfile()
        
        self.transition = JTMaterialTransition(animatedView: self.addButton)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setupTableCell() {
        let nib = UINib(nibName: "ListsCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
    }

    func getUserProfile() {
        if let userUid = keyChain.get("uid") {
            FirebaseProvider.shared.getUserProfile(userUid: userUid, completion: { (userSetting, error) in
                if error == nil {
                    self.userSetting = userSetting
                }
            })
        }
    }

    @objc func join(sender: UIButton) {
        sender.tintColor = UIColor.gray
        if let cell = sender.superview?.superview?.superview as? ListsCell,
            let indexPath = tableView.indexPath(for: cell) {
            cell.numLabel.textColor = UIColor.gray
            let joinId = results[indexPath.row].id
            let newVaule = results[indexPath.row].number + 1

            ref.child("user_joinId").childByAutoId().setValue(["user": uid, "joinId": joinId])
            ref.child("activities").child(joinId).child("number").setValue(newVaule)
        }
    }

    func getPosts() {
        FirebaseProvider.shared.getPosts(childKind: "joinId", completion: { (posts, error) in
            if let posts = posts {
                self.myMatches = Array(posts.values)
                self.tableView.reloadData()
            }
        })
    }

    @objc func showSearchView() {
        guard let searchView = UINib.load(nibName: "SearchView") as? SearchViewController else {
            print("SearchViewController invalid")
            return
        }
        searchView.mainViewController = self
        searchView.view.frame = CGRect(x: UIScreen.main.bounds.width - 150, y: (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height,
                                       width: 150, height: UIScreen.main.bounds.height)

        if !isShowed {
            self.addChildViewController(searchView)
            self.thisSearchView = searchView
            self.view.addSubview(searchView.view)
            searchView.didMove(toParentViewController: self)
            isShowed = true
        } else {
            thisSearchView?.willMove(toParentViewController: nil)
            thisSearchView?.view.removeFromSuperview()
            thisSearchView?.removeFromParentViewController()
            self.fetch()
            isShowed = false
        }
    }

    @objc func showAddView() {
        guard let activityView = UINib.load(nibName: "ActivityController") as? ActivityController else {
            print("ActivityController invalid")
            return
        }
//        navigationController?.pushViewController(activityView, animated: true)
        activityView.modalPresentationStyle = .custom
        activityView.transitioningDelegate = self.transition
//        navigationController?.pushViewController(activityView, animated: true)
        self.present(activityView, animated: true, completion: nil)

    }

    func search(selected: Preference) {
        FirebaseProvider.shared.getTypeData(selected: selected, completion: { [weak self] (results, error) in
            if error == nil {
                if results?.count == 0 {
                    SCLAlertView().showNotice(NSLocalizedString("Not found any activity.", comment: ""), subTitle: "")
                }
                self?.results = results!
                self?.tableView.reloadData()
            }
        })
    }

    @objc func fetch() {
        FirebaseProvider.shared.getData(completion: { [weak self] (results, error) in
            if error == nil {
                self?.results = results!
                self?.tableView.reloadData()
            }
        })
    }

    func setNavigation() {
        navigationItem.title = "Sporty"
        let searchButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-search"), style: .plain, target: self, action: #selector(showSearchView))
        navigationItem.rightBarButtonItems = [searchButton]
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "icon-left")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "icon-left")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationController?.navigationBar.tintColor = .white
    }

    func setUpAddButton() {
        addButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
    }
}

extension ListsController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ListsCell else {
            fatalError("Invalid ListsCell")
        }
        let result = results[indexPath.row]

        cell.setCell(result)
        var isMyMatch = false

        if result.authorUid != uid {
            for myMatch in myMatches where myMatch.id == result.id {
                isMyMatch = true
            }
            if result.number < result.allNumber && !isMyMatch {
                cell.setJoinButtonStatus(isEnable: true, tintColor: myIndigo, labelTextColor: myIndigo, statusText: "可參加")
                cell.joinButton.addTarget(self, action: #selector(self.join), for: .touchUpInside)

            } else if isMyMatch {
                cell.setJoinButtonStatus(isEnable: false, tintColor: .gray, labelTextColor: .gray, statusText: "已參加")

            } else if result.number == result.allNumber {
                cell.setJoinButtonStatus(isEnable: false, tintColor: .gray, labelTextColor: .gray, statusText: "人數已滿")

            }
        } else {
            cell.setJoinButtonStatus(isEnable: false, tintColor: .clear, labelTextColor: myIndigo, statusText: "招募中")
        }

        if result.type == userSetting?.preference.type {
            cell.recommendImage.image = UIImage(named: "icon-thumb")
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailView = UINib.load(nibName: "ShowDetailController") as? ShowDetailController else {
            print("ShowDetailController invalid")
            return
        }
        detailView.selectedActivity = results[indexPath.row]
        navigationController?.pushViewController(detailView, animated: true)
    }
}

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

class ListsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
            self.tableView.reloadData()
        }
    }
    
    var uid = Auth.auth().currentUser?.uid
    
    var ref = Database.database().reference()
    
    var myMatches = [Activity]()
    var tableView = UITableView()
    
    let searchView = UINib.load(nibName: "SearchView") as! SearchViewController
    
    lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(showAddView), for: .touchUpInside)
        button.setImage(UIImage(named: "icon-add"), for: .normal)
        button.tintColor = myPurple
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var joinIcon = UIImage(named: "icon-join")?.withRenderingMode(.alwaysTemplate)

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = .clear
                
        tableView.delegate = self
        
        tableView.dataSource = self
        
        tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - (tabBarController?.tabBar.frame.height)!)
        
        tableView.separatorStyle = .none
        
        self.view.addSubview(tableView)
        
        self.view.addSubview(addButton)

        setUpAddButton()

        setupTableCell()
        
        setNavigation()
        
        fetch()
        
        getPosts()
        
        getUserProfile()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupTableCell() {
        let nib = UINib(nibName: "ListsCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
    }
    
    func getUserProfile() {
        FirebaseProvider.shared.getUserProfile(completion: { (userSetting, error) in
            if error == nil {
                self.userSetting = userSetting
            }
        })
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListsCell
        let result = results[indexPath.row]
        
        cell.titleLabel.text = result.name
        cell.timeLabel.text = result.time
        cell.placeLabel.text = result.place.placeName
        cell.numLabel.text = "\(result.number) / \(result.allNumber)"
        var isMyMatch = false
        
        switch result.level {
        case .A: cell.levelImage.image = UIImage(named: "labelA")
        case .B: cell.levelImage.image = UIImage(named: "labelB")
        case .C: cell.levelImage.image = UIImage(named: "labelC")
        case .D: cell.levelImage.image = UIImage(named: "labelD")
       }
        
        if result.authorUid != uid {
            for myMatch in myMatches where myMatch.id == result.id {
                isMyMatch = true
            }
            if result.number < result.allNumber && !isMyMatch {
                cell.joinButton.isEnabled = true
                cell.joinButton.setImage(joinIcon, for: .normal)
                cell.joinButton.tintColor = myRed
                cell.joinButton.addTarget(self, action: #selector(self.join), for: .touchUpInside)
            } else {
                cell.joinButton.isEnabled = false
                cell.joinButton.setImage(joinIcon, for: .normal)
                cell.joinButton.tintColor = UIColor.gray
            }
            
        } else {
            cell.joinButton.isEnabled = false
            cell.joinButton.setImage(joinIcon, for: .normal)
            cell.joinButton.tintColor = UIColor.clear
        }
                
        switch result.type {
        case "羽球": cell.imagePlaced.image = UIImage(named: "badminton")!
        case "棒球": cell.imagePlaced.image = UIImage(named: "baseball")!
        case "籃球": cell.imagePlaced.image = UIImage(named: "basketball")!
        case "排球": cell.imagePlaced.image = UIImage(named: "volleyball")!
        case "網球": cell.imagePlaced.image = UIImage(named: "tennis")!
        case "足球": cell.imagePlaced.image = UIImage(named: "soccer")!
        default:
            return cell
        }
        
        if result.type == userSetting?.preference.type {
            cell.recommendImage.image = UIImage(named: "icon-thumb")
        }
        
        return cell
    }
    
    @objc func join(sender: UIButton) {
        sender.tintColor = UIColor.gray
        if let cell = sender.superview?.superview as? ListsCell,
            let indexPath = tableView.indexPath(for: cell) {
            let joinId = results[indexPath.row].id
            let newVaule = results[indexPath.row].number + 1
            
            ref.child("user_joinId").childByAutoId().setValue(["user": uid, "joinId": joinId])
            ref.child("activities").child(joinId).child("number").setValue(newVaule)
        }
    }
    
    func getPosts() {
        FirebaseProvider.shared.getPosts(childKind: "joinId", completion: { (posts, keyUid, error) in
            self.myMatches = posts!
            self.tableView.reloadData()
        })
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let activityView = UINib.load(nibName: "ActivityController") as! ActivityController
        activityView.selectedActivity = results[indexPath.row]
        navigationController?.pushViewController(activityView, animated: true)
    }
    
    @objc func showSearchView() {
        searchView.mainViewController = self
        searchView.view.frame = CGRect(x: UIScreen.main.bounds.width - 150, y: (self.navigationController?.navigationBar.frame.height)! + 20, width: 150, height: UIScreen.main.bounds.height)
        
        if !isShowed {
            self.addChildViewController(searchView)
            self.view.addSubview(searchView.view)
            searchView.didMove(toParentViewController: self)
            isShowed = true
        } else {
            searchView.willMove(toParentViewController: nil)
            searchView.view.removeFromSuperview()
            searchView.removeFromParentViewController()
            isShowed = false
        }
    }
    
    @objc func showAddView() {
        let activityView = UINib.load(nibName: "ActivityController") as! ActivityController
        navigationController?.pushViewController(activityView, animated: true)
    }
    
    func search(selected: Preference) {
        FirebaseProvider.shared.getTypeData(selected: selected, completion: { [weak self] (results, error) in
            if error == nil {
                self?.results = results!
                self?.tableView.reloadData()
            }
        })
    }
    
    @objc func fetch() {
        FirebaseProvider.shared.getData(completion: { (results, error) in
            if error == nil {
                self.results = results!
                self.tableView.reloadData()
            }
        })
    }
    
    func setNavigation() {
//        navigationItem.title = "Title"
        let searchButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-search"), style: .plain, target: self, action: #selector(showSearchView))
        let allButton = UIBarButtonItem(title: "All", style: .plain, target: self, action: #selector(fetch))
        navigationItem.rightBarButtonItems = [searchButton, allButton]
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

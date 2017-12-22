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
    
    var uid = Auth.auth().currentUser?.uid
    
    var ref = Database.database().reference()
    
    var myMatches = [Activity]()
    var tableView = UITableView()
    
    lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor.black
        button.layer.shadowRadius = 2
        button.addTarget(self, action: #selector(showAddView), for: .touchUpInside)
        button.setImage(UIImage(named: "icon-add"), for: .normal)
        
        return button
    }()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
        var uid = Auth.auth().currentUser?.uid
        
        keyChain.set(uid!, forKey: "uid")
        
        tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        self.view.addSubview(tableView)
        
        self.addButton.frame = CGRect(x: 330, y: 600, width: 50, height: 50)
        
        self.view.addSubview(addButton)

        setupTableCell()
        setNavigation()
        if selectedPreference == nil {
            fetch()
        }
        getPosts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupTableCell() {
        let nib = UINib(nibName: "ListsCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
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
        cell.levelLabel.text = result.level.rawValue
        cell.placeLabel.text = result.place.placeName
        cell.numLabel.text = "\(result.number) / \(result.allNumber)"
        var isMyMatch = false
        if result.authorUid != uid {
            for myMatch in myMatches where myMatch.id == result.id {
                isMyMatch = true
            }
            if result.number < result.allNumber && !isMyMatch {
                cell.joinButton.isEnabled = true
                cell.joinButton.backgroundColor = UIColor.blue
                cell.joinButton.tintColor = UIColor.white
                cell.joinButton.addTarget(self, action: #selector(self.join), for: .touchUpInside)
            } else {
                cell.joinButton.isEnabled = false
                cell.joinButton.backgroundColor = UIColor.gray
                cell.joinButton.tintColor = UIColor.white
            }
            
        } else {
            cell.joinButton.isEnabled = false
            cell.joinButton.backgroundColor = UIColor.clear
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
        return cell
    }
    
    @objc func join(sender: UIButton) {
        sender.backgroundColor = UIColor.gray
        sender.tintColor = UIColor.white
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
        return 165
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let activityView = UINib.load(nibName: "ActivityView") as! ActivityController
        activityView.selectedActivity = results[indexPath.row]
        navigationController?.pushViewController(activityView, animated: true)
    }
    
    @objc func showSearchView() {
        let searchView = UINib.load(nibName: "SearchView") as! SearchViewController
        searchView.mainViewController = self
        searchView.view.frame = CGRect(x: 0, y: (self.navigationController?.navigationBar.frame.height)!, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//        if !isShowed {
//            isShowed = !isShowed
            self.addChildViewController(searchView)

            self.view.addSubview(searchView.view)
            searchView.didMove(toParentViewController: self)
//        } else {
//            searchView.view.removeFromSuperview()
//        }
    }
    
    @objc func showAddView() {
        let activityView = UINib.load(nibName: "ActivityView") as! ActivityController
        navigationController?.pushViewController(activityView, animated: true)
    }
    
    func search(selected: Preference) {
        FirebaseProvider.shared.getData(selected: selected, completion: { (results, error) in
            if error == nil {
                self.results = results!
                self.tableView.reloadData()
            }
        })
    }
    
    @objc func fetch() {
        FirebaseProvider.shared.getData(selected: nil, completion: { (results, error) in
            if error == nil {
                self.results = results!
                self.tableView.reloadData()
            }
        })
    }

    func setNavigation() {
        navigationItem.title = "Title"
        let searchButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-home"), style: .plain, target: self, action: #selector(showSearchView))
        let allButton = UIBarButtonItem(title: "All", style: .plain, target: self, action: #selector(fetch))
        navigationItem.rightBarButtonItems = [searchButton, allButton]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        let logOutButton = UIBarButtonItem(title: "LogOut", style: .plain, target: self, action: #selector(logOut))
        let myProfile = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .plain, target: self, action: #selector(showMenu))
        navigationItem.leftBarButtonItems = [myProfile, logOutButton]
    }
    
    @objc func logOut() {
        
        keyChain.delete("uid")
        keyChain.delete("email")
        keyChain.delete("password")
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let loginController = storyboard.instantiateViewController(withIdentifier: "loginController")
        present(loginController, animated: true, completion: nil)

    }
    
    @objc func showMenu() {
        let myProfileController = UINib.load(nibName: "MyProfileController") as! MyProfileController
//        myProfileController.mainViewController = self
//        myProfileController.view.frame = CGRect(x: 0, y: (self.navigationController?.navigationBar.frame.height)!, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//
//        self.addChildViewController(myProfileController)
//
//        self.view.addSubview(myProfileController.view)
//        myProfileController.didMove(toParentViewController: self)
        navigationController?.pushViewController(myProfileController, animated: true)
//
    }
}

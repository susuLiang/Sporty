//
//  TableViewController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/13.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase

class ListsController: UITableViewController {
    
    var results = [Activity]()
    
    var selectedPreference: Preference? {
        didSet {
            search(selected: selectedPreference!)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableCell()
        setNavigation()
        tableView.delegate = self
        tableView.dataSource = self
        if selectedPreference == nil {
            fetch()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupTableCell() {
        let nib = UINib(nibName: "ListsCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListsCell
        cell.titleLabel.text = results[indexPath.row].id
        cell.timeLabel.text = results[indexPath.row].time
        cell.levelLabel.text = results[indexPath.row].level.rawValue
        cell.typeLabel.text = results[indexPath.row].type.rawValue
        cell.placeLabel.text = results[indexPath.row].place.placeName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let activityView = UINib.load(nibName: "ActivityView") as! ActivityController
        activityView.selectedActivity = results[indexPath.row]
        navigationController?.pushViewController(activityView, animated: true)
    }
    
    @objc func showSearchView() {
        let searchView = UINib.load(nibName: "SearchView") as! SearchViewController
        searchView.mainViewController = self
        self.addChildViewController(searchView)
        searchView.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)
        self.view.addSubview(searchView.view)
        searchView.didMove(toParentViewController: self)
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
}

extension ListsController {
    
    @objc func fetch() {
        FirebaseProvider.shared.getData(selected: nil, completion: { (results, error) in
            if error == nil {
                self.results = results!
                self.tableView.reloadData()
            }
        })
    }
}

extension ListsController {

    func setNavigation() {
        navigationItem.title = "Title"
        let addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(showAddView))
        let searchButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-home"), style: .plain, target: self, action: #selector(showSearchView))
        let allButton = UIBarButtonItem(title: "All", style: .plain, target: self, action: #selector(fetch))
        navigationItem.rightBarButtonItems = [addButton, searchButton, allButton]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LogOut", style: .plain, target: self, action: #selector(logOut))
    }
    
    @objc func logOut() {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let loginController = storyboard.instantiateViewController(withIdentifier: "loginController")
        present(loginController, animated: true, completion: nil)
        
        
    }
}

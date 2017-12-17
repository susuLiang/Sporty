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
        print("self:\(self)")
        return self.results.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("indexPath:\(indexPath)")
        print("self:\(self)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListsCell
        cell.titleLabel.text = results[indexPath.row].id
        cell.timeLabel.text = results[indexPath.row].time
        cell.levelLabel.text = results[indexPath.row].level.rawValue
        cell.typeLabel.text = results[indexPath.row].type.rawValue
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
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
        self.results = [Activity]()
        let ref = Database.database().reference().child("activities").queryOrdered(byChild: "type").queryEqual(toValue: selected.type.rawValue)
        ref.observe(.value, with: { (snapshot: DataSnapshot) in
            guard let snapShotData = snapshot.value as? [String: AnyObject] else { return }
            for (activitiesId, activitiesData) in snapShotData {
                let id = activitiesId
                if
                    let type = activitiesData["type"] as? String,
                    let time = activitiesData["time"] as? String,
                    let place = activitiesData["place"] as? String,
                    let level = activitiesData["level"] as? String,
                    let address = activitiesData["address"] as? String,
                    let number = activitiesData["number"] as? Int,
                    let allNumber = activitiesData["allNumber"] as? Int,
                    let fee = activitiesData["fee"] as? Int,
                    let author = activitiesData["author"] as? String {
                        if time == selected.time && place == selected.place && level == selected.level.rawValue {
                            let activities = (Activity(id: id, level: Level(rawValue: level)!, place: place, address: address, time: time, type: Sportstype(rawValue: type)!, number: number, allNumber: allNumber, fee: fee, author: author))
                            self.results.append(activities)
                        }
                }
            }
            print("self", self)
            self.tableView.reloadData()
        })
    }
}

extension ListsController {
    
    func fetch() {
        
        Database.database().reference().child("activities").observe(.value) { (snapshot: DataSnapshot) in
            self.results = [Activity]()
            print("snap", snapshot)
            if let objects = snapshot.value as? [String: AnyObject] {
                for (id, data) in objects {
                    let id = id
                    if
                        let type = data["type"] as? String,
                        let time = data["time"] as? String,
                        let place = data["place"] as? String,
                        let level = data["level"] as? String,
                        let address = data["address"] as? String,
                        let number = data["number"] as? Int,
                        let allNumber = data["allNumber"] as? Int,
                        let fee = data["fee"] as? Int,
                        let author = data["author"] as? String
                        {
                            self.results.append(Activity(id: id, level: Level(rawValue: level)!, place: place, address: address, time: time, type: Sportstype(rawValue: type)!, number: number, allNumber: allNumber, fee: fee, author: author))
                        }
                }
                self.tableView.reloadData()
            }
        }
    }
}

extension ListsController {

    func setNavigation() {
        navigationItem.title = "Title"
        let addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(showAddView))
        let searchButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-home"), style: .plain, target: self, action: #selector(showSearchView))
        navigationItem.rightBarButtonItems = [addButton, searchButton]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    }
}

    
    
    
    


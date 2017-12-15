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
    
    var results = [Preference]()
    
    var selectedPreference: Preference? {
        
        didSet {
            tableView?.reloadData()
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
        } else {
            search(selected: selectedPreference!)
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
        return results.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    @objc func showSearchView() {
        let searchView = UINib.load(nibName: "SearchView") as! SearchViewController
        self.addChildViewController(searchView)
        searchView.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)
        self.view.addSubview(searchView.view)
        searchView.didMove(toParentViewController: self)
    }
    
    func search(selected: Preference) {
        results = [Preference]()
        let ref = Database.database().reference().child("activities").queryOrdered(byChild: "type").queryEqual(toValue: selected.type.rawValue)
        ref.observe(.value, with: { (snapshot: DataSnapshot) in
            guard let snapShotData = snapshot.value as? [String: AnyObject] else { return }
            for (activitiesId, activitiesData) in snapShotData {
                let id = activitiesId
                guard let type = activitiesData["type"] as? String else { return }
                guard let level = activitiesData["level"] as? String else { return }
                guard let place = activitiesData["place"] as? String else { return }
                guard let time = activitiesData["time"] as? String else { return }
                if time == selected.time && level == selected.level.rawValue && place == selected.place {
                    let activities = Preference(id: id, type: Sportstype(rawValue: type)!, level: Level(rawValue: level)!, place: place, time: time)
                    self.results.append(activities)
                }
            }
            print("self", self.results)
            self.tableView.reloadData()
        })
    }

}

//extension ListsController: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        self.isSearch = true
//        print(self.isSearch)
//        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
//        searchTextField.addSubview(activityIndicator)
//        activityIndicator.frame = searchTextField.bounds
//        activityIndicator.startAnimating()
//
//        let searchText = searchTextField.text ?? ""
//        self.searchAuthor(type: searchText)
//
//        searchTextField.text = nil
//        searchTextField.resignFirstResponder()
//        activityIndicator.stopAnimating()
//        return true
//    }
//}

extension ListsController {
    
    func fetch() {
        
        Database.database().reference().child("activities").observe(.value) { (snapshot: DataSnapshot) in
            self.results = [Preference]()
            print("snap", snapshot)
            if let objects = snapshot.value as? [String: AnyObject] {
                for (id, data) in objects {
                    let id = id
                    if
                        let type = data["type"] as? String,
                        let time = data["time"] as? String,
                        let place = data["place"] as? String,
                        let level = data["level"] as? String {
                        self.results.append(Preference(id: id, type: Sportstype(rawValue: type)!, level: Level(rawValue: level)!, place: place, time: time))
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-home"), style: .plain, target: self, action: #selector(showSearchView))
    }
}

    
    
    
    


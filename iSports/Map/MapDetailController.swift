//
//  MapDetailController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/25.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit

class MapDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView = UITableView()

    var selectedPlaceActivities = [Activity]()

    var mainViewController: MapController?

    var headerView = UITableViewHeaderFooterView()

    var selectedPlace: Place? {

        didSet {
            FirebaseProvider.shared.getPlaceAllActivities(place: selectedPlace, completion: { (results, error) in
                self.selectedPlaceActivities = results!
                self.tableView.reloadData()
            })
        }
    }
    
    lazy var backButton: UIButton = {
       let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        view.addSubview(backButton)

        tableView.frame = CGRect(x: 0, y: 400, width: UIScreen.main.bounds.width, height: 300)

        tableView.delegate = self

        tableView.dataSource = self

        tableView.separatorStyle = .none

        setupTableCell()

        view.addSubview(tableView)

    } 

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedPlaceActivities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ListsCell else {
            fatalError("Invalid ListsCell")
        }
        let result = selectedPlaceActivities[indexPath.row]
        cell.setCell(result)
        cell.joinButton.isHidden = true

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

        switch result.level {
        case "A": cell.levelImage.image = UIImage(named: "labelA")
        case "B": cell.levelImage.image = UIImage(named: "labelB")
        case "C": cell.levelImage.image = UIImage(named: "labelC")
        case "D": cell.levelImage.image = UIImage(named: "labelD")
        default:
            break
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerWidth = headerView.frame.width
        let headerHeight = headerView.frame.height
        let placeLabel = UILabel()
        placeLabel.frame = CGRect(x: 0, y: 0, width: headerWidth, height: headerHeight)
        placeLabel.text = selectedPlace?.placeName
        placeLabel.textAlignment = .center
        placeLabel.backgroundColor = myLightBlue
        headerView.addSubview(placeLabel)
        return headerView
    }

    func setupTableCell() {
        let nib = UINib(nibName: "ListsCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
    }

    @objc func close() {
        self.view.removeFromSuperview()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let activityView = UINib.load(nibName: "ActivityController") as? ActivityController else {
            print("MapDetailController invalid")
            return
        }
        activityView.selectedActivity = selectedPlaceActivities[indexPath.row]
        self.navigationController?.pushViewController(activityView, animated: true)
    }

}

//
//  MapDetailController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/25.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import KeychainSwift
import Crashlytics

class MapDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView = UITableView()

//    var keyChain = KeychainSwift()

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

        tableView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 300, width: UIScreen.main.bounds.width, height: 300)

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
        cell.buttonStatusLabel.isHidden = true
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
        guard let showDetailView = UINib.load(nibName: "ShowDetailController") as? ShowDetailController else {
            print("ShowDetailController invalid")
            return
        }
        showDetailView.selectedActivity = selectedPlaceActivities[indexPath.row]
        self.navigationController?.pushViewController(showDetailView, animated: true)
    }

}

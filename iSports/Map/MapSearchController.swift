//
//  MapSearchController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/25.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit

class MapSearchController: UIViewController {

    var tableView = UITableView()
    var mainViewController: MapController?
    var selectedType: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame = CGRect(x: 0, y: 0, width: 150, height: UIScreen.main.bounds.height)
        view.backgroundColor = .white
        setTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setTableView() {
        tableView.frame = CGRect(x: 0, y: 0, width: 150, height: UIScreen.main.bounds.height - 30)
        tableView.alpha = 0.8
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(nibWithCellClass: MapSearchCell.self)
        tableView.separatorStyle = .none
        view.addSubview(tableView)
    }
}

extension MapSearchController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: MapSearchCell.self, for: indexPath)
        cell.typeLabel.text = typeArray[indexPath.row]
        return cell
    }
}

extension MapSearchController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedType = typeArray[indexPath.row]
        mainViewController?.selectedType = self.selectedType
        self.view.removeFromSuperview()
    }
}


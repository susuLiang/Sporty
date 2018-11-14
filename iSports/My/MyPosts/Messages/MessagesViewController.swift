//
//  MessagesViewController.swift
//  iSports
//
//  Created by Susu Liang on 2018/1/8.
//  Copyright © 2018年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase
import KeychainSwift
import Nuke
import SCLAlertView
import Crashlytics

class MessagesViewController: UIViewController {

    let keyChain = KeychainSwift()
    var messages: [Message] = []
    var thisActivityUid: String = "" {
        didSet {
            FirebaseProvider.shared.getMessage(postUid: thisActivityUid, completion: {(messages, error) in
                if error == nil {
                    self.messages = messages!
                    self.messages.sort(by: {
                        $0.date < $1.date
                    })
                    self.userUids = []
                    for message in self.messages where !self.userUids.contains(message.userUid) {
                        self.userUids.append(message.userUid)
                    }
                }
            })
        }
    }

    var userSetting: [String: UserSetting] = [:]
    var userUids: [String] = [] {
        didSet {
            for userUid in userUids {
                FirebaseProvider.shared.getUserProfile(userUid: userUid, completion: { (userSetting, error) in
                    if error == nil {
                        self.userSetting.updateValue(userSetting!, forKey: userUid)
                    }
                    self.tableView.reloadData()
                    if self.tableView.numberOfRows(inSection: 0) > 0 {
                        let lastRow: Int = self.tableView.numberOfRows(inSection: 0) - 1
                        let indexPath = IndexPath(row: lastRow, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                })
            }
        }
    }

    @IBAction func close(_ sender: Any) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBAction func sendMessage(_ sender: Any) {
        let userUid = Auth.auth().currentUser?.uid
        if typeTextField.text == "" {
            SCLAlertView().showError(NSLocalizedString("Error", comment: ""), subTitle: NSLocalizedString("Please enter something.", comment: ""))
        } else if let text = typeTextField.text {
            let ref = Database.database().reference().child("messages").childByAutoId()
            let date = "\(Date())"
            let value = ["userUid": userUid, "message": text, "postUid": thisActivityUid, "date": date] as [String: Any]
            ref.updateChildValues(value)
            self.typeTextField.text = ""
        }
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        setUpCell()
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sendButton.setTitle(NSLocalizedString("Send", comment: ""), for: .normal)
    }

    func setUpCell() {
        let nib = UINib(nibName: "MessageCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 22
    }
}

extension MessagesViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MessageCell else {
            fatalError("MessageCell Error")
        }
        let message = messages[indexPath.row]
        cell.userMessage.text = message.message
        if userSetting.count == userUids.count {
            if let userSetting = userSetting[message.userUid] {
                cell.userName.text = "\(userSetting.name):"
                if let userUrl = userSetting.urlString {
                    DispatchQueue.main.async {
                        Nuke.loadImage(with: URL(string: userUrl)!, into: cell.userPhoto)
                    }
                }
            }
        }
        return cell
    }
}

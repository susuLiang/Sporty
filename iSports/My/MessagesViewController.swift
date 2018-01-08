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

class MessagesViewController: UIViewController {
    
    let keyChain = KeychainSwift()
    
    var messages: [Message] = []
    var thisActivityUid: String = "" {
        didSet {
            print(thisActivityUid)
            FirebaseProvider.shared.getMessage(postUid: thisActivityUid, completion: {(messages, userUids, error) in
                if error == nil {
                    self.messages = messages!
                    self.messages.sort(by: {
                        $0.date < $1.date
                    })
                    self.userUids = userUids!
                }
            })
        }
    }
    
    var userSetting: [UserSetting] = []
    var userUids: [String] = [] {
        didSet {
            for user in userUids {
                FirebaseProvider.shared.getUserProfile(userUid: user, completion: { (userSetting, error) in
                    self.userSetting.append(userSetting!)
                    self.tableView.reloadData()
                })
            }
        }
    }

    @IBAction func close(_ sender: Any) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBAction func sendMessage(_ sender: Any) {
        let userUid = Auth.auth().currentUser?.uid
        if let text = typeTextField.text {
            let ref = Database.database().reference().child("messages").childByAutoId()
            let date = "\(Date())"
            let value = ["userUid": userUid, "message": text, "postUid": thisActivityUid, "date": date] as [String : Any]
            ref.setValue(value)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCell()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUpCell() {
        let nib = UINib(nibName: "MessageCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableViewAutomaticDimension
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
        cell.userMessage.text = messages[indexPath.row].message
        if userSetting.count == messages.count {
            cell.userName.text = "\(userSetting[indexPath.row].name):"
            if let userUrl = userSetting[indexPath.row].urlString {
                DispatchQueue.main.async {
                    Nuke.loadImage(with: URL(string: userUrl)!, into: cell.userPhoto)
                }
            }
        }
        return cell
    }
}


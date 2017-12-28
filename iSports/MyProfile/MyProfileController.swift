//
//  MyProfileController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/21.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase
import KeychainSwift
import SkyFloatingLabelTextField
import Fusuma
import SCLAlertView
import Nuke

class MyProfileController: UIViewController, UITextFieldDelegate, FusumaDelegate {
   
    let keyChain = KeychainSwift()
    
    let fusuma = FusumaViewController()
    
    var userImage = UIImage()
    
    var userSetting: UserSetting? = nil
    
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var pickPhotoButton: UIButton!
    @IBAction func logOut(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Log out", message: "Be sure to log out?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Sure", style: .default, handler: { (action) in
            self.keyChain.clear()
            
            do {
                try Auth.auth().signOut()
            } catch let logoutError {
                print(logoutError)
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginController = storyboard.instantiateViewController(withIdentifier: "loginController")
            self.present(loginController, animated: true, completion: nil)
            
        }))
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    

    @IBAction func pickPhoto(_ sender: Any) {
        self.present(fusuma, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserProfile()
        
        fusuma.delegate = self
        fusuma.cropHeightRatio = 0.6
        
        setNavigationBar()
        setLogOutButton()
        
        nameTextField.delegate = self
        nameTextField.isEnabled = false
        
        pickPhotoButton.isEnabled = false
        
        nameTextField.text = keyChain.get("name")
        userPhoto.layer.cornerRadius = 100
        userPhoto.clipsToBounds = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getUserProfile() {
        FirebaseProvider.shared.getUserProfile(completion: { (userSetting, error) in
            if error == nil {
                self.userSetting = userSetting
                self.nameTextField.text = self.userSetting?.name
                if userSetting?.urlString != nil {
                    Nuke.loadImage(with: URL(string: (self.userSetting?.urlString)!)!, into: self.userPhoto)
                    self.userPhoto.contentMode = .scaleAspectFill
                }
            }
        })
    }
    
    func loadUserPhoto() {
        Nuke.loadImage(with: URL(string: (self.userSetting?.urlString)!)!, into: self.userPhoto)
        self.userPhoto.contentMode = .scaleAspectFill
    }
    
    
    @objc func showBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func setLogOutButton() {
        logOutButton.layer.cornerRadius = 20
        logOutButton.layer.shadowRadius = 5
    }
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        userPhoto.image = image
        self.userImage = image
        userPhoto.contentMode = .scaleAspectFill
    }
    
    @objc func edit() {
        let saveIcon = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-save"), style: .plain, target: self, action: #selector(showAlert))
        navigationItem.rightBarButtonItem = saveIcon
        nameTextField.isEnabled = true
        pickPhotoButton.isEnabled = true
    }
    
    @objc func showAlert() {
        let editIt = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-edit"), style: .plain, target: self, action: #selector(edit))
        navigationItem.rightBarButtonItem = editIt
        nameTextField.isEnabled = false
        pickPhotoButton.isEnabled = false
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("SURE", action: self.saveIt)
        alertView.addButton("NO") {
        }
        alertView.showWarning("Sure to save it ?", subTitle: "")
    }
    
    func saveIt() {
        
        guard let editedName = nameTextField.text, let userUid = keyChain.get("uid") else { return }
        
        var data = Data()
        
        data = UIImageJPEGRepresentation(userPhoto.image!, 0.6)!
        
        let ref = Database.database().reference()
        
        let storageRef = Storage.storage().reference()
        
        let metadata = StorageMetadata()
        
        
        metadata.contentType = "image/jpg"
        
        storageRef.child(userUid).putData(data,metadata: metadata) { (metadata, error) in
            
            guard let metadata = metadata else {
                
                // Todo: error handling
                
                return
            }
            
            let downloadURL = metadata.downloadURL()?.absoluteString
            
            let value = ["name": editedName, "imageURL": downloadURL]

            ref.child("users").child(userUid).updateChildValues(value)
        
        }
        
    }

   
    func setNavigationBar() {
        let myProfile = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-menu"), style: .plain, target: self, action: #selector(showBack))
        let editIt = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-edit"), style: .plain, target: self, action: #selector(edit))
        navigationItem.leftBarButtonItems = [myProfile]
        navigationItem.rightBarButtonItem = editIt
    }
    
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
    }
    
    func fusumaCameraRollUnauthorized() {
    }

}

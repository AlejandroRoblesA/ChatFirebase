//
//  ViewController.swift
//  ChatFirebase
//
//  Created by Alejandro on 8/19/19.
//  Copyright © 2019 Alejandro. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let ref = Database.database().reference(fromURL: "https://chat-11c7d.firebaseio.com/")
//        ref.updateChildValues(["someValue": 123123])
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    }
    
    @objc func handleLogout(){
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
}


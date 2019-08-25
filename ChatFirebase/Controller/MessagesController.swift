//
//  ViewController.swift
//  ChatFirebase
//
//  Created by Alejandro on 8/19/19.
//  Copyright © 2019 Alejandro. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class MessagesController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Chat", style: .plain, target: self, action: #selector(handleNewMessage))
        
        //navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "blade"), style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
    }
    
    @objc func handleNewMessage(){
        let newMessageController = NewMessageController()
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn(){
        if (Auth.auth().currentUser?.uid == nil){
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        else{
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    self?.navigationItem.title = dictionary["name"] as? String
                }
            }, withCancel: nil)
            
        }
    }
    
    @objc func handleLogout(){
        
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
}

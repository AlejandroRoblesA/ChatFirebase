//
//  NewMessageController.swift
//  ChatFirebase
//
//  Created by Alejandro on 8/24/19.
//  Copyright © 2019 Alejandro. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class NewMessageController: UITableViewController {
    
    let cellId = "cellId"

    var users: [User]?
    
    var messagesController: MessagesController?
    
    var timer: Timer?
    
    override func viewDidAppear(_ animated: Bool) {
        fetchUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    }
    
    func fetchUser() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
            
            for nodo in snapshot.children{
                if let nodoSnap = nodo as? DataSnapshot{
                    
                    if let nodoAux = nodoSnap.value as? [String: Any]{
                        
                        let userData = User()
                        
                        userData.key = nodoSnap.key
                        
                        userData.id = nodoSnap.key
                        
                        if (uid != userData.id){
                            if let name = nodoAux["name"] as? String{
                                userData.name = name
                            }
                            if let email = nodoAux["email"] as? String{
                                userData.email = email
                            }
                            if let imageURL = nodoAux["profileImageUrl"] as? String{
                                userData.profileImageUrl = imageURL
                            }
                            if (self.users != nil){
                                self.users?.append(userData)
                            }
                            else{
                                self.users = [userData]
                            }
                        }
                    }
                }
            }
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
        })
    }
    
    @objc func handleReloadTable(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users?[indexPath.row]
        cell.textLabel?.text = user?.name
        cell.detailTextLabel?.text = user?.email
        
        if let profileImageURL = user?.profileImageUrl{
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageURL)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            if let user = self.users?[indexPath.row]{
                self.messagesController?.showChatControllerForUser(user: user)
            }
        }
    }
    
}

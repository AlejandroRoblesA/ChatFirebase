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
    
    var messages: [Message]?
    var messagesDictionary = [String: Message]()
    let cellId = "cellId"
    
    override func viewDidAppear(_ animated: Bool) {
        //observeMessages()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Chat", style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    }
    
    func observeMessages(){
        
        
        
        let ref = Database.database().reference().child("messages")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            for nodo in snapshot.children{
                if let nodoSnap = nodo as? DataSnapshot{
                    if let nodoAux = nodoSnap.value as? [String: Any]{
                        let message = Message()
                        message.idMessage = nodoSnap.key
                        if let text = nodoAux["text"] as? String{
                            message.text = text
                        }
                        if let toId = nodoAux["toId"] as? String{
                            message.toId = toId
                        }
                        if let fromId = nodoAux["fromId"] as? String{
                            message.fromId = fromId
                        }
                        if let timestamp = nodoAux["timestamp"] as? NSNumber{
                            message.timestamp = timestamp
                        }
                        if let toId = message.toId{
                            self.messagesDictionary[toId] = message
                            self.messages = Array(self.messagesDictionary.values)
                            self.messages?.sort(by: { (message1, message2) -> Bool in
                                return message1.timestamp!.intValue > message2.timestamp!.intValue
                            })
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        })
    }
    
    func observeUserMessages(){
        messages?.removeAll()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("user-messages").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
            let nodo = snapshot.key
            let messagesReferences = Database.database().reference().child("messages").child(nodo)
            messagesReferences.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String:Any]{
                    let message = Message()
                    message.idMessage = snapshot.key
                    if let text = dictionary["text"] as? String{
                        message.text = text
                    }
                    if let toId = dictionary["toId"] as? String{
                        message.toId = toId
                    }
                    if let fromId = dictionary["fromId"] as? String{
                        message.fromId = fromId
                    }
                    if let timestamp = dictionary["timestamp"] as? NSNumber{
                        message.timestamp = timestamp
                    }
                    if let chatPartner = message.chatPartnerId(){
                        self.messagesDictionary[chatPartner] = message
                        self.messages = Array(self.messagesDictionary.values)
                        self.messages?.sort(by: { (message1, message2) -> Bool in
                            return message1.timestamp!.intValue > message2.timestamp!.intValue
                        })
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            })
            
        }, withCancel: nil)
    }
    
    
    @objc func handleNewMessage(){
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn(){
        if (Auth.auth().currentUser?.uid == nil){
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        else{
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in

        if let dictionary = snapshot.value as? [String: Any]{
            
            let userData = User()
                            
            userData.key = snapshot.key
            
            if let name = dictionary["name"] as? String{
                userData.name = name
            }
            if let email = dictionary["email"] as? String{
                userData.email = email
            }
            if let imageURL = dictionary["profileImageUrl"] as? String{
                userData.profileImageUrl = imageURL
            }
            
            self.setupNavBarWithUser(user: userData)
        }
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(user: User){
        
        messages?.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 18
        profileImageView.clipsToBounds = true
        
        if let profileImageUrl = user.profileImageUrl{
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        let nameLabel = UILabel()
        
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
    
        self.navigationItem.titleView = titleView
        
        //titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(showChatController))
//        navigationController?.view.addGestureRecognizer(tap)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let message = messages?[indexPath.row]
        
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages?[indexPath.row]
        
        guard let chatPartnerId = message?.chatPartnerId() else { return }
        
        let ref = Database.database().reference().child("Users").child(chatPartnerId)
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            print(snapshot)
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            let user = User()
            
            user.key = snapshot.key
            user.id = chatPartnerId
            if let name = dictionary["name"] as? String{
                user.name = name
            }
            if let email = dictionary["email"] as? String{
                user.email = email
            }
            if let imageURL = dictionary["profileImageUrl"] as? String{
                user.profileImageUrl = imageURL
            }
            self.showChatControllerForUser(user: user)
        }
        
        //
    }
    
    @objc func handleLogout(){
        
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        let loginController = LoginController()
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
    }
    
    @objc func showChatControllerForUser(user: User){
        
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
}

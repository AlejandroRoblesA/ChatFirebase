//
//  NewMessageController.swift
//  ChatFirebase
//
//  Created by Alejandro on 8/24/19.
//  Copyright © 2019 Alejandro. All rights reserved.
//

import UIKit
import FirebaseDatabase

class NewMessageController: UITableViewController {
    
    let cellId = "cellId"

    var users: [User]?
    
    override func viewDidAppear(_ animated: Bool) {
        fetchUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    }
    
    func fetchUser() {
        
        Database.database().reference().child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
            
            for nodo in snapshot.children{
                if let nodoSnap = nodo as? DataSnapshot{
                    
                    if let nodoAux = nodoSnap.value as? [String: Any]{
                        let userData = User()
                        userData.key = nodoSnap.key
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
            self.tableView.reloadData()
        })
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
    
}


class UserCell: UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y-2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2 , width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let profileImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

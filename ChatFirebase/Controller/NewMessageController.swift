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
        //fetchUser()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let user = users?[indexPath.row]
        cell.textLabel?.text = user?.name
        cell.detailTextLabel?.text = user?.email
        return cell
    }
}


class UserCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

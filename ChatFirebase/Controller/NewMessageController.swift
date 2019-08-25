//
//  NewMessageController.swift
//  ChatFirebase
//
//  Created by Alejandro on 8/24/19.
//  Copyright © 2019 Alejandro. All rights reserved.
//

import UIKit

class NewMessageController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
}

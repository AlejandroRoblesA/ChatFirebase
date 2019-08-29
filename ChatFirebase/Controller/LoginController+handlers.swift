//
//  LoginController+handlers.swift
//  ChatFirebase
//
//  Created by Alejandro on 8/28/19.
//  Copyright © 2019 Alejandro. All rights reserved.
//

import UIKit

extension LoginController{
    @objc func handleSelectProfileImageView(){
        let picker = UIImagePickerController()
        present(picker, animated: true, completion: nil)
    }
}



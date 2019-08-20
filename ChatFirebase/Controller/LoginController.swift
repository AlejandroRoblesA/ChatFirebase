//
//  LogoutController.swift
//  ChatFirebase
//
//  Created by Alejandro on 8/19/19.
//  Copyright © 2019 Alejandro. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
}

extension UIColor{
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        let newRed = CGFloat(r)/255
        let newGreen = CGFloat(g)/255
        let newBlue = CGFloat(b)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}


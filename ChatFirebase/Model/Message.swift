//
//  Message.swift
//  ChatFirebase
//
//  Created by Alejandro on 8/31/19.
//  Copyright © 2019 Alejandro. All rights reserved.
//

import UIKit
import FirebaseAuth

class Message: NSObject {

    var idMessage: String?
    var fromId:    String?
    var text:      String?
    var timestamp: NSNumber?
    var toId:      String?
    
    var imageUrl:  String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    
    var videoUrl: String?
    
    func chatPartnerId() -> String?{
        //return fromId == Auth.auth().currentUser?.uid ? toId!: fromId!
        if (fromId == Auth.auth().currentUser?.uid ){
            return toId
        }
        else{
            return fromId
        }
    }
}

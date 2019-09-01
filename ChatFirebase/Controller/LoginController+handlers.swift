//
//  LoginController+handlers.swift
//  ChatFirebase
//
//  Created by Alejandro on 8/28/19.
//  Copyright © 2019 Alejandro. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //var messagesController: MessagesController?
    //here it doesn't work because it is an extension, it needs to be declared on the viewController (LoginController)
    
    @objc func handleSelectProfileImageView(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let originalImage = info[.originalImage] as? UIImage  {
            selectedImageFromPicker = originalImage
        }
        else if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleRegister(){
        
        guard let email    = emailTextField.text,
            let password = passwordTextField.text,
            let name     = nameTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if (error != nil){
                print(error!)
                return
            }
            
            guard let uid = user?.user.uid else { return }
            
            let imageName = NSUUID().uuidString
            
            let storageReference = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            
            if let profileImageView = self.profileImageView.image{
                
                if let uploadData = profileImageView.jpegData(compressionQuality: 0.1){
                    
                    storageReference.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                        if (error != nil){
                            print(error!)
                            return
                        }
                        
                        storageReference.downloadURL(completion: { (url, error) in
                            if let profileImageURL = url?.absoluteString{
                                let values = ["name": name, "email": email, "profileImageUrl": profileImageURL]
                                self.registerUserIntoDatabaseWithUID(uid: uid, values: values)
                            }
                        })
                        
                        
                    })
                }
            }
        }
    }
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: Any]){
        let ref = Database.database().reference(fromURL: "https://chat-11c7d.firebaseio.com/")
        let userReference = ref.child("Users").child(uid)
        
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if (err != nil){
                print(err!)
                return
            }
            
//            self.messagesController?.fetchUserAndSetupNavBarTitle()
//            self.messagesController?.navigationItem.title = values["name"] as? String
            
                
                let userData = User()
            
            
                if let name = values["name"] as? String{
                    userData.name = name
                }
                if let imageURL = values["profileImageUrl"] as? String{
                    userData.profileImageUrl = imageURL
                }
                
                self.messagesController?.setupNavBarWithUser(user: userData)
            
            self.dismiss(animated: true, completion: nil)
        })
    }
}



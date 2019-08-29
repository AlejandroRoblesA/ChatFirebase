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
            
            let storageReference = Storage.storage().reference().child("myImage.png")
            
            if let uploadData = self.profileImageView.image!.pngData(){
                storageReference.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if (error != nil){
                        print(error!)
                        return
                    }
                    print(metadata!)
                })
            }
            
            
            
            let ref = Database.database().reference(fromURL: "https://chat-11c7d.firebaseio.com/")
            let userReference = ref.child("Users").child(uid)
            let values = ["name": name, "email": email]
            userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if (err != nil){
                    print(err!)
                    return
                }
                
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
}



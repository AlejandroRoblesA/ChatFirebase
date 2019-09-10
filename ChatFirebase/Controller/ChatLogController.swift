//
//  ChatLogController.swift
//  ChatFirebase
//
//  Created by Alejandro on 8/31/19.
//  Copyright © 2019 Alejandro. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var user: User?{
        didSet{
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Write your message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    let cellId = "cellId"
    
    var messages = [Message]()
    
    var containerViewButtomAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 10, right: 0)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView.keyboardDismissMode = .interactive
        
        setupKeyboardObservers()
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = .white
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "uploadImage")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        containerView.addSubview(uploadImageView)
        
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor,constant: 8).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 34).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 34).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        
        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
    @objc func handleUploadTap(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
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
            uploadToFirebaseStorageUsingImage(image: selectedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage){
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = image.jpegData(compressionQuality: 0.2){
            ref.putData(uploadData, metadata: nil) { (metadata, error) in
                if (error !=  nil){
                    return
                }
                
                ref.downloadURL(completion: { (url, error) in
                    if let imageUrl = url?.absoluteString{
                        self.sendMessageWithImageUrl(imageUrl: imageUrl, image: image)
                    }
                })
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override var inputAccessoryView: UIView?{
        get{
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    func setupKeyboardObservers(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyboardDidShow(){
        if messages.count > 0{
            let indexPath = IndexPath(item: messages.count-1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    @objc func handleKeyboardWillShow(notification: NSNotification){
        guard let info = notification.userInfo else { return }
        guard let value: NSValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        guard let valueDuration: Double = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        let keyboardFrame = value.cgRectValue
        let keyboardDuration = valueDuration
        
        containerViewButtomAnchor?.constant = -keyboardFrame.height
        
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleKeyboardWillHide(notification: NSNotification){
        
        guard let info = notification.userInfo else { return }
        guard let valueDuration: Double = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        let keyboardDuration = valueDuration
        
        containerViewButtomAnchor?.constant = 0
        
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        setupCell(cell: cell, message: message)
        if let text = message.text{
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        }
        else if (message.imageUrl != nil){
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message){
        
        if let profileImageUrl = self.user?.profileImageUrl{
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        if message.fromId == Auth.auth().currentUser?.uid{
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        }
        else{
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = .black
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.profileImageView.isHidden = false
        }
        
        if let messageImageUrl = message.imageUrl{
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .clear
        }
        else{
            cell.messageImageView.isHidden = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        if let text = message.text{
            height = estimateFrameForText(text: text).height + 20
        }
        else if let imageWidth = message.imageWidth?.floatValue,
                let imageHeight = message.imageHeight?.floatValue{
            
            //h1 / w1 = h2 / w2
            //h1 = h2 / w2 * w1
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        let width = UIScreen.main.bounds.width
        
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect{
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    @objc func handleSend(){
        
        let properties = ["text": inputTextField.text!] as [String : Any]
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage){
        
        let properties = ["imageUrl"   : imageUrl,
                          "imageWidth" : image.size.width,
                          "imageHeight": image.size.height] as [String : Any]
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithProperties(properties: [String: Any]){
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        var values = ["toId"       : toId,
                      "fromId"     : fromId,
                      "timestamp"  : timestamp] as [String : Any]
        //$0 = key, $1 = value
        properties.forEach({ values[$0] = $1 })
        
        
        childRef.updateChildValues(values) { (error, ref) in
            if (error != nil){
                print(error as Any)
                return
            }
            
            self.inputTextField.text = nil
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = childRef.key
            
            let dictionary = [messageId: 1] as? [String: Any]
            userMessagesRef.updateChildValues(dictionary!)
            
            let recipientUserMessageRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            
            recipientUserMessageRef.updateChildValues(dictionary!)
        }
    }
    
    func observeMessages(){
        
        guard let uid = Auth.auth().currentUser?.uid,
              let toId = user?.id else { return }
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            
            let messageRef = Database.database().reference().child("messages").child(messageId)
            
            messageRef.observe(.value, with: { (snapshot2) in
                
                guard let dictionary = snapshot2.value as? [String: Any] else { return }
                
                let message = Message()
                
                message.idMessage = snapshot2.key
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
                if let imageUrl = dictionary["imageUrl"] as? String{
                    message.imageUrl = imageUrl
                }
                if let imageWidth = dictionary["imageWidth"] as? NSNumber{
                    message.imageWidth = imageWidth
                }
                if let imageHeight = dictionary["imageHeight"] as? NSNumber{
                    message.imageHeight = imageHeight
                }
                
                self.messages.append(message)
                self.collectionView.reloadData()
                let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    func performZoomInForStartingImageView (startingImageView: UIImageView){
        print("Performing zoom")
        let startingFrame  = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        print(startingFrame)
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = .red
        
        if let keyWindow = UIApplication.shared.keyWindow {
            keyWindow.addSubview(zoomingImageView)
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: startingFrame!.height)
            }, completion: nil)
        }
    }
}

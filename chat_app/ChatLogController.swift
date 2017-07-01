//
//  ChatLogController.swift
//  chat_app
//
//  Created by Xiaoping Weng on 6/28/17.
//  Copyright © 2017 Xiaoping Weng. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var user: User? {
        didSet{
            navigationItem.title = user?.name
            observeMessage()
            
        }
    }
    var messages = [Message
        ]()
    func observeMessage(){
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else {
            return
        }
        
        let userMessageRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("Message").child(messageId)
            
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String:AnyObject] else{
                    return
                }
                
                //get all message
                let message = Message(dictionary: dictionary)

                //store only message belong to currentuser
                self.messages.append(message)
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.keyboardDismissMode = .interactive
        
        setupKeyboardObserver()
    }
    
    lazy var inputContainerView: ChatInputContainerView = {
        
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputContainerView.chatLogController = self
         
        return chatInputContainerView
    }()
    
    override var inputAccessoryView: UIView?{
        get{
            return inputContainerView
        }
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    func handleUploadTap(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL{
            
            handleVideoSelectedForUrl(url: videoUrl)
            
            }else{
            handleImageSelectedForInfo(info: info as [String : AnyObject])
        }

        dismiss(animated: true, completion: nil)
    }
    
    private func handleVideoSelectedForUrl(url: NSURL
        ){
        let fileUrl = NSUUID().uuidString
        let uploadTask = Storage.storage().reference().child("message-video").child(fileUrl).putFile(from: url as URL, metadata: nil, completion: { (metadata, error) in
            
            if error != nil{
                print(error)
                return
            }
            
            if let videoUrl = metadata?.downloadURL()?.absoluteString{
                
                if let thumbnailImage = self.thumbnaiImageForfileUrl(fileUrl: url){
                    
                    self.uploadToFirebaseStorageUsingImage(image: thumbnailImage, completion: { (imageUrl) in
                        let ref = Database.database().reference().child("Message")
                        let childRef = ref.childByAutoId()
                        
                        let toId = self.user!.id!
                        let fromId = Auth.auth().currentUser!.uid
                        let timeStamp = Int(NSDate().timeIntervalSince1970)
                        let values = ["fromId": fromId, "videoUrl": videoUrl, "timestamp": timeStamp, "toId": toId, "imageWidth": thumbnailImage.size.width, "imageHeight": thumbnailImage.size.height, "imageUrl":  imageUrl] as [String : Any]
                        
                        childRef.updateChildValues(values)
                        
                        childRef.updateChildValues(values) { (error, ref) in
                            if error != nil{
                                print(error)
                            }
                            
                            self.inputContainerView.textField.text = nil
                            
                            let userMessageRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
                            
                            let messageId = childRef.key
                            userMessageRef.updateChildValues([messageId: 1])
                            
                            let recipinetUserMessageRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
                            
                            recipinetUserMessageRef.updateChildValues([messageId: 1])
                        }
                    })
                }
            }
        })

        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitsCount = snapshot.progress?.completedUnitCount{
                self.navigationItem.title = String(completedUnitsCount)
            }
        }
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
 
        }
        
    }
    
    private func thumbnaiImageForfileUrl(fileUrl:  NSURL) -> UIImage? {
        let asset = AVAsset(url: fileUrl as URL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        }catch let error{
            print(error)
        }
        return nil
    }
    
    private func handleImageSelectedForInfo(info: [String: AnyObject]){
        var selectedImage: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            selectedImage = editedImage
        }else if let originImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            selectedImage = originImage
        }
        
        if let selected = selectedImage{
            uploadToFirebaseStorageUsingImage(image: selected, completion: { (imageUrl) in
                self.sentMessageWithImageUrl(imageUrl: imageUrl, image: selected)
            })
        }
    }
    
    func uploadToFirebaseStorageUsingImage(image: UIImage, completion: @escaping (_ imageUrl: String) ->()){
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2){
            ref.putData(uploadData, metadata: nil, completion: { (metaData, error) in
                if error != nil{
                    print("failed to upload image", error)
                    return
                }
                
                if let imageUrl = metaData?.downloadURL()?.absoluteString{
                    completion(imageUrl)

                }
                
            })
        }
    }
    
    private func sentMessageWithImageUrl(imageUrl: String, image: UIImage){
        
        let ref = Database.database().reference().child("Message")
        let childRef = ref.childByAutoId()
        
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timeStamp = Int(NSDate().timeIntervalSince1970)
        let values = ["fromId": fromId, "imageUrl": imageUrl, "timestamp": timeStamp, "toId": toId, "imageWidth": image.size.width, "imageHeight": image.size.height] as [String : Any]
        
        childRef.updateChildValues(values)
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error)
            }
            
            self.inputContainerView.textField.text = nil
            
            let userMessageRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId: 1])
            
            let recipinetUserMessageRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            
            recipinetUserMessageRef.updateChildValues([messageId: 1])
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func setupKeyboardObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)

    }
    func handleKeyDidShow(){
        if messages.count > 0{

            let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
        }
    }
    
    func handleKeyWillShow(notification: NSNotification){
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuring = (notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as AnyObject).doubleValue
        
        containerViewButtomAnchor?.constant = -(keyboardFrame?.height)!
        UIView.animate(withDuration: keyboardDuring!) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidLoad()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleKeyWillHide(notification: NSNotification){
        let keyboardDuring = (notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as AnyObject).doubleValue
        
        containerViewButtomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuring!) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 15
        }else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue{
                height = CGFloat(imageHeight / imageWidth * 200)

        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: option, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? ChatMessageCell
        
        cell?.chatLogController = self
        
        let text = messages[indexPath.item]
        cell?.message = text
        
        cell?.textView.text = text.text
        setupCell(cell: cell!, text: text)
        
        if let textMessage = text.text {
            cell?.bubbleWidthAnchor?.constant = estimateFrameForText(text: textMessage).width + 20
            cell?.textView.isHidden = false
        }else if text.imageUrl != nil{
            cell?.bubbleWidthAnchor?.constant = 200
            cell?.textView.isHidden = true
        }
        
        cell?.playButton.isHidden = text.videoUrl == nil

        return cell!
    }
    
    private func setupCell(cell: ChatMessageCell, text: Message){
        if let profileImageUrl = self.user?.profileImageUrl{
            cell.profileImageview.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        if let messageImageUrl = text.imageUrl{
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        }else{
            cell.messageImageView.isHidden = true

        }
        
        if text.fromId == Auth.auth().currentUser?.uid{
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.bbleftAnchor?.isActive = false
            cell.bbRightAnchor?.isActive = true
            cell.profileImageview.isHidden = true
            
        }else{
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.bbRightAnchor?.isActive = false
            cell.bbleftAnchor?.isActive = true
            cell.profileImageview.isHidden = false

        }
    }
    
    var cellId = "cellId"
    var containerViewButtomAnchor: NSLayoutConstraint?
    
    func handleSentController(){
        let ref = Database.database().reference().child("Message")
        let childRef = ref.childByAutoId()
        
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timeStamp = Int(NSDate().timeIntervalSince1970)
        let values = ["fromId": fromId, "text": inputContainerView.textField.text!, "timestamp": timeStamp, "toId": toId] as [String : Any]
        
        childRef.updateChildValues(values)
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error)
            }
            
            self.inputContainerView.textField.text = nil
            
            let userMessageRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId: 1])
            
            let recipinetUserMessageRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            
            recipinetUserMessageRef.updateChildValues([messageId: 1])
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSentController()
        return true
    }
    
    var startingFram: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    func performZoominForStartingImageView(startingImageView: UIImageView){
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        startingFram = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        let zoominImageView = UIImageView(frame: startingFram!)
        zoominImageView.image = startingImageView.image
        
        zoominImageView.isUserInteractionEnabled = true
        zoominImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomout)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoominImageView)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                let height = self.startingFram!.height / self.startingFram!.width * keyWindow.frame.width
                
                zoominImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoominImageView.center = keyWindow.center
                
            }, completion: nil)
        }
    }
    func handleZoomout(tapGesture: UITapGestureRecognizer){

        if let zoomoutImageView = tapGesture.view{
            zoomoutImageView.layer.cornerRadius = 16
            zoomoutImageView.layer.masksToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomoutImageView.frame = self.startingFram!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1

            }, completion: { (completed: Bool) in
                zoomoutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false

            })
        
        }
 
    }
    
}






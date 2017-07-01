//
//  LoginController*handler.swift
//  chat_app
//
//  Created by Xiaoping Weng on 6/27/17.
//  Copyright © 2017 Xiaoping Weng. All rights reserved.
//

import UIKit
import Firebase

extension Login_Controller: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    func handProfile(){
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImage: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            selectedImage = editedImage
        }else if let originImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
    
            selectedImage = originImage
        }
        
        if let selected = selectedImage{
            loginImageView.image = selected
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("image pick cancelled")
        dismiss(animated: true, completion: nil)

    }
    
    //handling register button func
    func handleRegister() {
        guard let email = inputEmailTextField.text, let password = passwordTextfield.text, let name = inputNameTextField.text else{
            print ("input is invaild")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil{
                print(error)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            let imageName = NSUUID().uuidString
            
            let storageRef = Storage.storage().reference().child("profileImage").child("\(imageName).jpeg")
            
            if let storageImage = UIImageJPEGRepresentation(self.loginImageView.image!, 0.1){
            
            storageRef.putData(storageImage, metadata: nil) { (metadata, error) in
                if error != nil{
                    print(error)
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    
                    let values = ["name": name, "email": email, "profileImageUrl": imageUrl]
                    
                    self.registerUserWithUid(uid: uid, values: values as [String : AnyObject])
                    
                }
            }
                
            }
        }
    }
    
    private func registerUserWithUid(uid: String, values: [String: AnyObject]){
        
        
        let ref = Database.database().reference()
        let users = ref.child("users").child(uid)
        
        users.updateChildValues(values) { (err, ref) in
            if err != nil{
                print(err)
                return
            }
            
            self.messageController?.fetchUserAndSetNavbar()
            self.dismiss(animated: true, completion: nil)
        }
    }
}






//
//  ChatInputContainerView.swift
//  chat_app
//
//  Created by Xiaoping Weng on 7/1/17.
//  Copyright © 2017 Xiaoping Weng. All rights reserved.
//

import UIKit

class ChatInputContainerView: UIView, UITextFieldDelegate{
    
    var chatLogController: ChatLogController? {
        didSet{
            //sendbutton press
            sendButton.addTarget(chatLogController, action: #selector(ChatLogController.handleSentController), for: .touchUpInside)
            
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogController.handleUploadTap)))
        }
    }
    
    lazy var textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter here..."
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.delegate = self as? UITextFieldDelegate
        return tf
    }()
    
    let sendButton: UIButton = {
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        return sendButton
    }()
    
    let uploadImageView: UIImageView =  {
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "uploadImageIcon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        return uploadImageView
    }()
    
    let seLine: UIView = {
        let seLine = UIView()
        seLine.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        seLine.translatesAutoresizingMaskIntoConstraints = false
        return seLine
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        addSubview(uploadImageView)
        addSubview(sendButton)
        addSubview(self.textField)
        addSubview(seLine)

        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.isUserInteractionEnabled = true

        sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        self.textField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        self.textField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.textField.rightAnchor.constraint(equalTo: sendButton.leftAnchor ).isActive = true
        self.textField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        seLine.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        seLine.topAnchor.constraint(equalTo: topAnchor).isActive = true
        seLine.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        seLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatLogController?.handleSentController()
        return true
    }

}

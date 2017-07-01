//
//  ViewController.swift
//  chat_app
//
//  Created by Xiaoping Weng on 6/26/17.
//  Copyright © 2017 Xiaoping Weng. All rights reserved.
//

import UIKit
import Firebase

class MessageController: UITableViewController {
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout ", style: .plain, target: self, action: #selector(handlelogout))
        
        //create new bar button item
        let image = UIImage(named: "newMessageIcon")
        let button: UIButton = UIButton.init(type:.custom)
        button.setImage(image, for: UIControlState.normal)
        button.addTarget(self, action: #selector(handleNewMassage), for: UIControlEvents.touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        let barButton = UIBarButtonItem(customView: button)
        
        navigationItem.rightBarButtonItem = barButton
        
        checkUserisLogin()

        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)

        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let message = self.messageArray[indexPath.row]
        if let chatPartnerId = message.chatPartnerId(){
            Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
                if error != nil{
                    print(error)
                    return
                }
                
                self.messageDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadTable()
               // self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            })
        }
    }
    
    func observaUserMessage(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
            let userId = snapshot.key
            
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                self.fetchMessageWithMessageId(messageId: messageId)
                
            }, withCancel: nil)
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            self.messageDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadTable()
        }, withCancel: nil)
    }
    var timer: Timer?
    
    private func fetchMessageWithMessageId(messageId: String){
        let messageReference = Database.database().reference().child("Message").child(messageId)
        
        messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
                
                if let id = message.chatPartnerId(){
                    self.messageDictionary[id] = message
                }
                self.attemptReloadTable()
            }
            
        }, withCancel: nil)
        
    }
    
    private func attemptReloadTable(){
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    func handleReloadTable(){
        
        self.messageArray = Array(self.messageDictionary.values)
        
        //sort messages so that display recent one
        self.messageArray.sort(by: { (message1, message2) -> Bool in
            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
        })
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    var messageArray = [Message]()
    var messageDictionary = [String: Message]()
    
    func observaMessage(){
        let ref = Database.database().reference().child("Message")
        ref.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
                //self.messageArray.append(message)
                
                if let toId = message.toId{
                    self.messageDictionary[toId] = message
                    self.messageArray = Array(self.messageDictionary.values)
                    
                    //sort messages so that display recent one
                    self.messageArray.sort(by: { (message1, message2) -> Bool in
                        return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
                    })
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messageArray[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
            guard let dictionary = snapshot.value as? [String:AnyObject] else{
                return
            }
            
            let user = User()
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
            self.showChatController(user: user)
            
            
        }, withCancel: nil)
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let message = messageArray[indexPath.row]
        cell.message = message
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func handleNewMassage(){
        let newMessage = newMassageController()
        newMessage.messagesController = self
        
        let navigationController = UINavigationController(rootViewController: newMessage)
        present(navigationController, animated: true, completion: nil)
        
    }
    
    
    func checkUserisLogin(){
        if Auth.auth().currentUser?.uid == nil{
            perform(#selector(handlelogout), with: nil, afterDelay: 0)
        }else{
            fetchUserAndSetNavbar()
        }
    }
    
    func fetchUserAndSetNavbar(){
        
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        let nameLabal = UIView()
        
        //nameLabal.translatesAutoresizingMaskIntoConstraints = false
        nameLabal.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        //nameLabal.backgroundColor = UIColor.red
        self.navigationItem.titleView = nameLabal
        
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let naviTitle = UILabel()
                naviTitle.translatesAutoresizingMaskIntoConstraints = false
                
                nameLabal.addSubview(naviTitle)
                naviTitle.centerXAnchor.constraint(equalTo: nameLabal.centerXAnchor).isActive = true
                naviTitle.centerYAnchor.constraint(equalTo: nameLabal.centerYAnchor).isActive = true
                //naviTitle.widthAnchor.constraint(equalTo: nameLabal.widthAnchor).isActive = true
                naviTitle.heightAnchor.constraint(equalTo: nameLabal.heightAnchor).isActive = true
                naviTitle.text = dictionary["name"] as? String
                //self.navigationItem.title = dictionary["name"] as? String
                
                
                //clean out all messages
                self.messageArray.removeAll()
                self.messageDictionary.removeAll()
                self.tableView.reloadData()
                self.observaUserMessage()

            }
            
        }, withCancel: { (nil) in
        })
        
        //nameLabal.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
    }
    
    func showChatController(user: User){
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)

    }
    
    
    func handlelogout(){
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = Login_Controller();
        loginController.messageController = self
        present(loginController, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


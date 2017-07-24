//
//  userCell.swift
//  chat_app
//
//  Created by Xiaoping Weng on 6/28/17.
//  Copyright © 2017 Xiaoping Weng. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell{
    //this is test
    var message: Message? {
        didSet{
            
            setupNameAndProfileImage()
            
            self.detailTextLabel?.text = message?.text
            
            if let second = message?.timestamp?.doubleValue{
                let timestampData = NSDate(timeIntervalSince1970: second)
                let dataFomer = DateFormatter()
                dataFomer.dateFormat = "hh:mm:ss a"
                
                timeLable.text = dataFomer.string(from: timestampData as Date)
            }
        }
    }
    
    func setupNameAndProfileImage(){
        
        if let id = message?.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String:AnyObject] {
                    
                    if let imageUrl = dictionary["profileImageUrl"] as? String{
                        self.profileImageView.loadImageUsingCacheWithUrlString(urlString: imageUrl)
                    }
                    self.textLabel?.text = dictionary["name"] as? String
                }
                
            }, withCancel: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame =
            CGRect(x: 64, y: (textLabel?.frame.origin.y)! - 2, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        
        detailTextLabel?.frame =
            CGRect(x: 64, y: (detailTextLabel?.frame.origin.y)! + 2, width: (detailTextLabel?.frame.width)!, height: (detailTextLabel?.frame.height)!)
    }
    
    let profileImageView: UIImageView = {
        let piv = UIImageView()
        piv.image = UIImage(named: "newMess")
        piv.translatesAutoresizingMaskIntoConstraints = false
        piv.layer.cornerRadius = 24
        piv.layer.masksToBounds = true
        piv.contentMode = .scaleAspectFill
        return piv
    }()
    
    let timeLable: UILabel = {
       let lable = UILabel()
        lable.translatesAutoresizingMaskIntoConstraints = false
        lable.textColor = UIColor.darkGray
        lable.font = UIFont.systemFont(ofSize: 12)
        return lable
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLable)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        timeLable.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLable.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLable.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLable.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


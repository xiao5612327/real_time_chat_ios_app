//
//  ChatMessageCell.swift
//  chat_app
//
//  Created by Xiaoping Weng on 6/29/17.
//  Copyright © 2017 Xiaoping Weng. All rights reserved.
//

import UIKit
import AVFoundation

class ChatMessageCell: UICollectionViewCell {
    
    var message: Message?
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView()
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    let textView: UITextView = {
        let tf = UITextView()
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor.clear
        tf.textColor = .white
        tf.isEditable = false
        return tf
    }()
    
    let bubbleView: UIView = {
        let bb = UIView()
        bb.backgroundColor = blueColor
        bb.translatesAutoresizingMaskIntoConstraints = false
        bb.layer.cornerRadius = 16
        bb.layer.masksToBounds = true
        return bb
    }()
    
    let profileImageview: UIImageView = {
        let pi = UIImageView()
        pi.image = UIImage(named: "newMess")
        pi.translatesAutoresizingMaskIntoConstraints = false
        pi.layer.cornerRadius = 16
        pi.layer.masksToBounds = true
        pi.contentMode = .scaleAspectFill
        return pi
    }()
    
    var chatLogController: ChatLogController?

    lazy var messageImageView: UIImageView = {
        let miv = UIImageView()
        miv.translatesAutoresizingMaskIntoConstraints = false
        miv.layer.cornerRadius = 16
        miv.layer.masksToBounds = true
        miv.contentMode = .scaleAspectFill
        miv.isUserInteractionEnabled = true
        miv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return miv
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "play_button")
        
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return button
    }()
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    func handlePlay(){
        if let videoUrlString = message?.videoUrl, let url = NSURL(string: videoUrlString){
            player = AVPlayer(url: url as URL)
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            player?.play()
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
        }
    }
    
    
    func handleZoomTap(tapGesture: UITapGestureRecognizer){
        if message?.videoUrl != nil{
            return
        }
        
        if let imageView = tapGesture.view as? UIImageView{
            chatLogController?.performZoominForStartingImageView(startingImageView: imageView)
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
    }

    static let blueColor = UIColor(r: 0, g: 137, b: 249)
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bbRightAnchor: NSLayoutConstraint?
    var bbleftAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageview)
        
        bubbleView.addSubview(messageImageView)
        
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        bubbleView.addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        bubbleView.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        profileImageview.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageview.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageview.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageview.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        
        
        bbRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bbRightAnchor?.isActive = true
        
        bbleftAnchor  = bubbleView.leftAnchor.constraint(equalTo: profileImageview.rightAnchor, constant: 8)
        bbleftAnchor?.isActive = false
        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
            
        bubbleWidthAnchor?.isActive = true
        
        //ios 9 contraints 
        //xywidth height
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

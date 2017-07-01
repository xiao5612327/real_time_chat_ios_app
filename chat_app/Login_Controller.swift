//
//  Login Controller.swift
//  chat_app
//
//  Created by Xiaoping Weng on 6/26/17.
//  Copyright © 2017 Xiaoping Weng. All rights reserved.
//

import UIKit
import Firebase

class Login_Controller: UIViewController {
    
    var messageController: MessageController?
    
    let inputContainer: UIView = {
        let input = UIView()
        input.backgroundColor = UIColor.white
        input.translatesAutoresizingMaskIntoConstraints = false
        input.layer.cornerRadius = 5
        input.layer.masksToBounds = true
        return input
    }()
    
    let inputRegistorButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(r: 80, g: 91, b: 151)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        //adding button press action
        button.addTarget(self, action: #selector(handleLoginRegistor), for: .touchUpInside)
        return button
    }()
    
    
    let inputNameTextField: UITextField = {
        let iname = UITextField()
        iname.placeholder = "Name"
        iname.translatesAutoresizingMaskIntoConstraints = false
        iname.layer.masksToBounds = true
        return iname
    }()
    
    let inputSeparet: UIView = {
        let Sline = UIView()
        Sline.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        Sline.translatesAutoresizingMaskIntoConstraints = false
        return Sline
    }()
    
    let inputEmailSeparet: UIView = {
        let Sline = UIView()
        Sline.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        Sline.translatesAutoresizingMaskIntoConstraints = false
        return Sline
    }()
    
    
    
    let inputEmailTextField: UITextField = {
        let tt = UITextField()
        tt.placeholder = "Email Address"
        tt.translatesAutoresizingMaskIntoConstraints = false
        return tt
    }()
    
    let passwordTextfield: UITextField = {
        let pass = UITextField()
        pass.placeholder = "password"
        pass.translatesAutoresizingMaskIntoConstraints = false
        pass.isSecureTextEntry = true
        return pass
    }()
    
    lazy var loginImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile_imge")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handProfile)))
        
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    
    
    let loginRegisterSegementedControll: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        
        sc.addTarget(self, action: #selector(handleSegmentChanged), for: .valueChanged)
        return sc
    }()
    
    func handleSegmentChanged(){
        let title = loginRegisterSegementedControll.titleForSegment(at: loginRegisterSegementedControll.selectedSegmentIndex)
        inputRegistorButton.setTitle(title, for: .normal)
        
        inputTextFieldHeightAnchor?.isActive = false
        inputTextFieldHeightAnchor = inputContainer.heightAnchor.constraint(equalToConstant: loginRegisterSegementedControll.selectedSegmentIndex == 1 ? 150: 100)
        inputTextFieldHeightAnchor?.isActive = true
        
        
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = inputNameTextField.heightAnchor.constraint(equalTo: inputContainer.heightAnchor, multiplier: loginRegisterSegementedControll.selectedSegmentIndex == 0 ? 0 : 1/3)
        
        nameTextFieldHeightAnchor?.isActive = true
        
        
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = inputEmailTextField.heightAnchor.constraint(equalTo: inputContainer.heightAnchor, multiplier: loginRegisterSegementedControll.selectedSegmentIndex == 1 ? 1/3 : 1/2)
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextfield.heightAnchor.constraint(equalTo: inputContainer.heightAnchor, multiplier: loginRegisterSegementedControll.selectedSegmentIndex == 1 ? 1/3 : 1/2)
        passwordTextFieldHeightAnchor?.isActive = true


    }
    
    
    func handleLoginRegistor(){
        if loginRegisterSegementedControll.selectedSegmentIndex == 0{
            handleLogin()
        }else{
            handleRegister()
        }
    }
    
    func handleLogin(){
        guard let email = inputEmailTextField.text, let password = passwordTextfield.text else{
            print("error")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil{
                print(error)
                return
            }
            
            self.messageController?.fetchUserAndSetNavbar()
            self.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 80, g: 100, b: 151)
        
        view.addSubview(inputContainer)
        view.addSubview(inputRegistorButton)
        view.addSubview(loginImageView)
        view.addSubview(loginRegisterSegementedControll)
        
        
        setupInputContainer()
        setupInputRegistorButton()
        setupInputImageView()
        setupSegementedControll()
    }
    
    func setupSegementedControll(){
        loginRegisterSegementedControll.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegementedControll.bottomAnchor.constraint(equalTo: inputContainer.topAnchor, constant: -12).isActive = true
        loginRegisterSegementedControll.heightAnchor.constraint(equalToConstant: 40).isActive = true
        loginRegisterSegementedControll.widthAnchor.constraint(equalTo: inputContainer.widthAnchor).isActive = true
        
    }
    
    func setupInputImageView(){
        loginImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginImageView.bottomAnchor.constraint(equalTo: loginRegisterSegementedControll.topAnchor, constant: -12).isActive = true
        loginImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        loginImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    var inputTextFieldHeightAnchor: NSLayoutConstraint?
    
    func setupInputContainer() {
        //need x, y width, height
        inputContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true;
        inputContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true;
        inputContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true;
        inputTextFieldHeightAnchor = inputContainer.heightAnchor.constraint(equalToConstant: 150)
        inputTextFieldHeightAnchor?.isActive = true;
        
        //need x, y width, height
        
        inputContainer.addSubview(inputNameTextField)
        inputNameTextField.leftAnchor.constraint(equalTo: inputContainer.leftAnchor, constant: 24).isActive = true
        inputNameTextField.topAnchor.constraint(equalTo: inputContainer.topAnchor).isActive = true
        inputNameTextField.widthAnchor.constraint(equalTo: inputContainer.widthAnchor).isActive = true
        
        nameTextFieldHeightAnchor = inputNameTextField.heightAnchor.constraint(equalTo: inputContainer.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        //need x, y width, height
        inputContainer.addSubview(inputSeparet)
        inputSeparet.leftAnchor.constraint(equalTo: inputContainer.leftAnchor).isActive = true
        inputSeparet.topAnchor.constraint(equalTo: inputNameTextField.bottomAnchor).isActive = true
        inputSeparet.heightAnchor.constraint(equalToConstant: 1).isActive = true
        inputSeparet.widthAnchor.constraint(equalTo: inputContainer.widthAnchor).isActive = true
        
        //need x, y, width, height
        
        inputContainer.addSubview(inputEmailTextField)
        inputEmailTextField.topAnchor.constraint(equalTo: inputNameTextField.bottomAnchor).isActive = true
        inputEmailTextField.leftAnchor.constraint(equalTo: inputNameTextField.leftAnchor).isActive = true
        emailTextFieldHeightAnchor = inputEmailTextField.heightAnchor.constraint(equalTo: inputContainer.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        inputEmailTextField.widthAnchor.constraint(equalTo: inputNameTextField.widthAnchor).isActive = true
        
        
        //need x, y width, height
        inputContainer.addSubview(inputEmailSeparet)
        inputEmailSeparet.leftAnchor.constraint(equalTo: inputContainer.leftAnchor).isActive = true
        inputEmailSeparet.topAnchor.constraint(equalTo: inputEmailTextField.bottomAnchor).isActive = true
        inputEmailSeparet.heightAnchor.constraint(equalToConstant: 1).isActive = true
        inputEmailSeparet.widthAnchor.constraint(equalTo: inputNameTextField.widthAnchor).isActive = true
        
        //need x, y, width, height
        inputContainer.addSubview(passwordTextfield)
        passwordTextfield.topAnchor.constraint(equalTo: inputEmailTextField.bottomAnchor).isActive = true
        passwordTextfield.leftAnchor.constraint(equalTo: inputEmailTextField.leftAnchor).isActive = true
        passwordTextfield.widthAnchor.constraint(equalTo: inputEmailTextField.widthAnchor).isActive = true
        
        
        passwordTextFieldHeightAnchor = passwordTextfield.heightAnchor.constraint(equalTo: inputContainer.heightAnchor, multiplier: 1/3)
        
        passwordTextFieldHeightAnchor?.isActive = true
        
    }
    
    func setupInputRegistorButton(){
        //need x, y width, height
        
        inputRegistorButton.centerXAnchor.constraint(equalTo: inputContainer.centerXAnchor).isActive = true
        
        inputRegistorButton.topAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: 12).isActive = true
        inputRegistorButton.widthAnchor.constraint(equalTo: inputContainer.widthAnchor).isActive = true
        inputRegistorButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    
   /* override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .lightContent
    }*/
    
}

extension UIColor{
    
    convenience init(r:CGFloat, g:CGFloat, b:CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}

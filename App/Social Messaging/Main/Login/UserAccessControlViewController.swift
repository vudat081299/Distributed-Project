//
//  UserAccessControlViewController.swift
//  MyMapKit
//
//  Created by Vũ Quý Đạt  on 17/12/2020.
//

import UIKit

class UserAccessControlViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var csTopContainerView: NSLayoutConstraint!
    @IBOutlet weak var csTopSigninView: NSLayoutConstraint!
    @IBOutlet weak var signinView: UIView!
    @IBOutlet weak var layerUsernameTextField: UIView!
    @IBOutlet weak var usernameTextFieldContainer: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var layerPasswordTextField: UIView!
    @IBOutlet weak var passwordTextFieldContainer: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var domainInput: UITextField!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var animationLoadingView: NVActivityIndicatorView!
    //    @IBOutlet weak var testanimation: NVActivityIndicatorView!
    var keyboardHeight: CGFloat = 0.0
    
    var isChangePageByPageControl = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        title = "Social Messaging"

        // Do any additional setup after loading the view.
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // set up UI
        animationLoadingView.type = .cubeTransition
        
        layerUsernameTextField.border()
        layerUsernameTextField.dropShadow()
        usernameTextFieldContainer.border()
        usernameTextFieldContainer.dropShadow()
        layerPasswordTextField.border()
        layerPasswordTextField.dropShadow()
        passwordTextFieldContainer.border()
        passwordTextFieldContainer.dropShadow()
        
        usernameTextField.text = "vudat81299"
        passwordTextField.text = "vudat81299"
        domainInput.text = domain
    }
    
    // MARK: - Common methods
    func edditingUserName() {
        UIView.animate(withDuration: 0.3,
                       delay: 0.1,
                       options: [.curveEaseIn],
                       animations: { [weak self] in
                        self!.csTopContainerView.constant = self!.view.frame.height / 2
                        self?.view.layoutIfNeeded()
                       }, completion: nil)
    }
    func endEdditingUserName() {
        
    }
    func edditingPassword() {
        
    }
    func endEdditingPassword() {
        
    }
    
    func startLoading(_ handler: @escaping () -> Void) {
        startLoadingAnimation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            handler()
            self.stopLoadingAnimation()
        }
    }
    
    func startLoadingAnimation () {
        UIView.animate(withDuration: 0.3,
                       delay: 0.1,
                       options: [.curveEaseIn],
                       animations: { [weak self] in
                        self!.view.endEditing(true)
                        self!.loadingView.isHidden = false
                        self!.view.bringSubviewToFront(self!.loadingView)
                        self!.loadingView.alpha = 1
                        self!.animationLoadingView.startAnimating()
                       }, completion: nil)
    }
    
    func stopLoadingAnimation () {
        UIView.animate(withDuration: 1,
                       delay: 0.5,
                       options: [.curveEaseIn],
                       animations: { [weak self] in
                        self!.loadingView.alpha = 0
                       }, completion: {_ in
                        self.loadingView.isHidden = true
                        self.view.sendSubviewToBack(self.loadingView)
                        self.animationLoadingView.stopAnimating()
                       })
    }
    
    // MARK: IBAction
    @IBAction func loginButtonTap(_ sender: UIButton) {
        domain = domainInput.text
        guard let username = usernameTextField.text, !username.isEmpty else {
            ErrorPresenter.showError(message: "Please enter your username", on: self)
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            ErrorPresenter.showError(message: "Please enter your password", on: self)
            return
        }
        
        Auth.login(username: username, password: password) { result in
            switch result {
            case .success:
                
                DispatchQueue.main.async { [self] in
                    startLoading {
//                        let appDelegate = UIApplication.shared.delegate as? SceneDelegate
//                        appDelegate?.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
//                        self.addChild(UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!)
                        
                        // using with storyboard reference
//                        startLoading {
//                            self.performSegue(withIdentifier: "didLogin", sender: nil)
//                        }
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated:true, completion:nil)
                    }
                }
            case .failure:
                let message = "Could not login. Check your credentials and try again"
                ErrorPresenter.showError(message: message, on: self)
            }
        }
        
        
//        DidRequestServer.successful(on:self)
//        startLoading {
//            self.performSegue(withIdentifier: "didLogin", sender: nil)
//        }
    }
    
    @IBAction func hideKeyBoardTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func pageControlTapped(_ sender: UIPageControl) {
        
    }
    
    @IBAction func typingUsername(_ sender: UITextField) {
        
    }
    
    @IBAction func endTypingUsername(_ sender: UITextField) {
        
    }
    
    @IBAction func typingPassword(_ sender: Any) {
        
    }
    
    @IBAction func endTypingPassword(_ sender: UITextField) {
        
    }
    
    @IBAction func customIpAction(_ sender: UIButton) {
//        ip = usernameTextField.text!
        if passwordTextField.text == "true" {
//            demo = true
        } else {
//            demo = false
        }
    }
    
    // MARK: Observer methods
    
    
    
    // MARK: - Delegate methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}

//MARK: Keyboard.
extension UserAccessControlViewController: UITextFieldDelegate {
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardRect.height
            UIView.animate(withDuration: 0.3,
                           delay: 0.1,
                           options: [.curveEaseIn],
                           animations: { [weak self] in
                            self!.csTopContainerView.constant = -50
                            self?.view.layoutIfNeeded()
                           }, completion: nil)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        csTopContainerView.constant = 0
        view.layoutIfNeeded()
//            if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//                UIView.animate(withDuration: 0.3,
//                               delay: 0.1,
//                               options: [.curveEaseIn],
//                               animations: { [weak self] in
//                               }, completion: nil)
    }
}


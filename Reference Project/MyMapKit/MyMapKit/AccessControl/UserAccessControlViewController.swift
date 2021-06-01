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
    @IBOutlet weak var welcomeScrollView: UIScrollView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var signinView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var animationLoadingView: NVActivityIndicatorView!
    //    @IBOutlet weak var testanimation: NVActivityIndicatorView!
    var keyboardHeight: CGFloat = 0.0
    
    var isChangePageByPageControl = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        pageControl.addTarget(self, action: #selector(touchDragOutsidePageControl), for: UIControl.Event.touchDragOutside)
        pageControl.addTarget(self, action: #selector(touchUpInsidePageControl), for: UIControl.Event.touchUpInside)
        pageControl.addTarget(self, action: #selector(touchUpOutsidePageControl), for: UIControl.Event.touchUpOutside)
        
        // set up UI
        animationLoadingView.type = .cubeTransition
        pageControl.numberOfPages = Int(contentStackView.frame.size.width / self.view.frame.size.width)
        pageControl.currentPage = 0
        
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
        UIView.animate(withDuration: 0.5,
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
    @IBAction func pageControlChange(_ sender: UIPageControl) {
        welcomeScrollView.setContentOffset(CGPoint(x: welcomeScrollView.frame.size.width * CGFloat(sender.currentPage), y: welcomeScrollView.frame.origin.y), animated: true)
        isChangePageByPageControl = true
    }
    
    @IBAction func loginButtonTap(_ sender: UIButton) {
        startLoading {
            self.performSegue(withIdentifier: "didLogin", sender: nil)
        }
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
    
    
    // MARK: Observer methods
    @objc func touchDragOutsidePageControl() {
        isChangePageByPageControl = false
    }
    
    @objc func touchUpInsidePageControl() {
        isChangePageByPageControl = false
    }
    
    @objc func touchUpOutsidePageControl() {
        isChangePageByPageControl = false
    }
    
    // MARK: - Delegate methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isChangePageByPageControl {
            pageControl.currentPage = Int(scrollView.contentOffset.x / self.view.frame.size.width)
        }
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
                            let a = (self!.view.frame.height - self!.keyboardHeight) / 2
                            let b = self!.welcomeScrollView.frame.size.height + self!.signinView.frame.origin.x +  self!.signinView.frame.size.height / 2
                            self!.csTopContainerView.constant = a - b
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


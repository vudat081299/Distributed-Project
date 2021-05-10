//
//  SignUpViewController.swift
//  MyMapKit
//
//  Created by HungPH on 19/12/2020.
//

/*










-------------------------------------------
Đĩ mẹ mày code kiểu đéo j mà kéo lắm UI thế
-------------------------------------------
rep: bm làm trong 1 tiếng ra cái này thì chỉ thế thôi











*/







import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var gradienBg: UIGradientView!
    
    @IBOutlet weak var scrollInputView: UIScrollView!
    
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var currentProgressDot: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var imageBg: UIImageView!
    
    @IBOutlet weak var fullname: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var phonenumber: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmpassword: UITextField!
    
    @IBOutlet weak var fn1: UIView!
    @IBOutlet weak var fn2: UIView!
    @IBOutlet weak var un1: UIView!
    @IBOutlet weak var un2: UIView!
    @IBOutlet weak var pn1: UIView!
    @IBOutlet weak var pn2: UIView!
    @IBOutlet weak var em1: UIView!
    @IBOutlet weak var em2: UIView!
    @IBOutlet weak var pw1: UIView!
    @IBOutlet weak var pw2: UIView!
    @IBOutlet weak var cp1: UIView!
    @IBOutlet weak var cp2: UIView!
    @IBOutlet weak var bt1: UIButton!
    @IBOutlet weak var bt2: UIButton!
    @IBOutlet weak var bt3: UIButton!
    @IBOutlet weak var bt4: UIButton!
    @IBOutlet weak var bt5: UIButton!
    
    @IBOutlet weak var layerBackButton: UIView!
    @IBOutlet weak var layerConfirmButton: UIView!
    
    @IBOutlet weak var backStepButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    let x = UIImage(named: "x")?.withRenderingMode(.alwaysTemplate)
    var lastContentOffset: CGFloat! = 0
    var satelliteSize: CGFloat = 0.0
    var inputTitle = ["Your full name", "Username", "Phone number", "Email", "Password", "Confirm password"]
    var inputTextList: [UITextField]!
    var viewList: [UIView]!
    var buttonList: [UIButton]!
    var currentInputIndex = 0
    
    var createUserFormData = CreateUserFormData(name: "", username: "", password: "", email: "", phonenumber: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // data
        viewList = [fn1, un1, pn1, em1, pw1, cp1, fn2, un2, pn2, em2, pw2, cp2, layerBackButton, layerConfirmButton, backStepButton, confirmButton]
        buttonList = [bt1, bt2, bt3, bt4, bt5]
        inputTextList = [fullname, username, phonenumber, email, password, confirmpassword]

        // Do any additional setup after loading the view.
        progressView.minEdgeBorder()
        currentProgressDot.roundedBorder()
        backButton.setImage(x, for: .normal)
        backButton.tintColor = .white
        
        setupAnimationBg()
        setUpView()
        fullname.becomeFirstResponder()
    }
    
    func setUpView() {
        borderAllViewIn(viewList)
        setUpButton(buttonList)
        
        backStepButton.isEnabled = false
        backStepButton.setTitleColor(.lightGray, for: .disabled)
    }
    
    func borderAllViewIn(_ array: [UIView]) {
        for (index, value) in array.enumerated() {
            value.border()
            if index > 5 {
                value.dropShadow()
            }
        }
    }
    
    func setUpButton(_ array: [UIButton]) {
        let rightArrow = UIImage(named: ">")?.withRenderingMode(.alwaysTemplate)
        for value in array {
            value.setImage(rightArrow, for: .normal)
            value.tintColor = .darkGray
        }
    }
    
    func setupAnimationBg() {
//            let duration: CFTimeInterval = 30
//
//            // Animation
//            let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
//
//            animation.keyTimes = [0, 0.5, 1]
//            animation.values = [0, -Double.pi, -2 * Double.pi]
//            animation.duration = duration
//            animation.repeatCount = HUGE
//            animation.isRemovedOnCompletion = false
//
//        imageBg.layer.add(animation, forKey: "animation")
    }
    
    // next
    func setOffSet() {
        switchResponder()
        
        backStepButton.isEnabled = true
        
        scrollInputView.setContentOffset(CGPoint(x: CGFloat(currentInputIndex) * view.frame.size.width, y:0), animated: true)
        
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: [.curveEaseIn],
                       animations: { [weak self] in
                        self!.currentProgressDot.frame.origin.x = self!.progressView.frame.origin.x + 3 + CGFloat(self!.currentInputIndex) * ((self!.progressView.frame.size.width - 6 - self!.currentProgressDot.frame.size.width) / 5)
                        self?.view.layoutIfNeeded()
                       }, completion: nil)

    }
    
    // back
    func setBackOffSet() {
        switchResponder()
        
        scrollInputView.setContentOffset(CGPoint(x: CGFloat(currentInputIndex) * view.frame.size.width, y:0), animated: true)
        
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: [.curveEaseIn],
                       animations: { [weak self] in
                        self!.currentProgressDot.frame.origin.x = self!.progressView.frame.origin.x + 3 + CGFloat(self!.currentInputIndex) * ((self!.progressView.frame.size.width - 6 - self!.currentProgressDot.frame.size.width) / 5)
                        self?.view.layoutIfNeeded()
                       }, completion: nil)
    }
    
    func switchResponder() {
        switch currentInputIndex {
        case 1:
            username.becomeFirstResponder()
        case 2:
            phonenumber.becomeFirstResponder()
        case 3:
            email.becomeFirstResponder()
        case 4:
            password.becomeFirstResponder()
        case 5:
            confirmpassword.becomeFirstResponder()
        default:
            fullname.becomeFirstResponder()
        }
    }
    
    func validateInput() -> Bool {
        for i in inputTextList {
            if i.text == "" || i.text == nil {
                MessagePresenter.showMessage(message: "Please fill completely in all fields!", on: self)
                return false
            }
        }
        if password.text != confirmpassword.text {
            MessagePresenter.showMessage(message: "Confirmed password didn't match!", on: self)
            return false
        }
        let accountForm = CreateUserFormData(name: fullname.text!, username: username.text!, password: password.text!.description, email: email.text!, phonenumber: phonenumber.text!)
        createUserFormData = accountForm
        return true
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func backButtonAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func bt1Action(_ sender: UIButton) {
        currentInputIndex = 1
        setOffSet()
    }
    @IBAction func bt2Action(_ sender: UIButton) {
        currentInputIndex = 2
        setOffSet()
    }
    @IBAction func bt3Action(_ sender: UIButton) {
        currentInputIndex = 3
        setOffSet()
    }
    @IBAction func bt4Action(_ sender: UIButton) {
        currentInputIndex = 4
        setOffSet()
    }
    @IBAction func bt5Action(_ sender: UIButton) {
        currentInputIndex = 5
        setOffSet()
    }
    
    @IBAction func hideKeyBoardTap(_ sender: UITapGestureRecognizer) {
//        self.view.endEditing(true)
    }
    @IBAction func backStepAction(_ sender: UIButton) {
        if currentInputIndex > 0 {
            currentInputIndex -= 1
            setBackOffSet()
        }
    }
    @IBAction func confirmAction(_ sender: UIButton) {
        confirmButton.isEnabled = false
        if !validateInput() {
            confirmButton.isEnabled = true
            return
        }
        let user = createUserFormData
        ResourceRequest<CreateUserFormData, ResponseCreateUser>(resourcePath: "users").saveuser(user) { [weak self] result in
            switch result {
            case .failure:
                print("upload fail")
                ErrorPresenter.showError(message: "There was a problem creating user!", on: self) {_ in
                    self!.confirmButton.isEnabled = true
                }
            case .success:
                DispatchQueue.main.async { [weak self] in
                    print("successful created annotation!")
                    DidRequestServer.successful(on: self, title: "Sucessful create your account!")
                }
            }
        }
    }
    
}

extension SignUpViewController: UIScrollViewDelegate {
//    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
//        <#code#>
//    }
    
    // do not enabled paging
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        let layout = self.listInputCollectionView?.collectionViewLayout as! UICollectionViewFlowLayout
//        var cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
//        cellWidthIncludingSpacing = view.frame.size.width - 45
//        var offset = targetContentOffset.pointee
//        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
//        let roundedIndex = round(index)
//        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
////        print("\(layout.itemSize.width) - \(layout.minimumLineSpacing)")
////        print("\(cellWidthIncludingSpacing) - \(offset) - \(index) - \(roundedIndex) - \(roundedIndex)")
//        targetContentOffset.pointee = offset
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag == 1 && scrollView.contentOffset.x < -15.0 {
            navigationController?.popViewController(animated: true)
        }
        
        
        if scrollView.tag == 0 && scrollInputView.contentOffset.x == 0.0 {
            backStepButton.isEnabled = false
        }
//        if (2.2 > scrollView.contentOffset.x) {
//            // move up
//        }
//        else if (lastContentOffset < scrollView.contentOffset.x) {
//           // move down
//        }
//
//        // update the new position acquired
//        lastContentOffset = scrollView.contentOffset.x
    }
}















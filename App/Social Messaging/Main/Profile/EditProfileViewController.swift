//
//  EditProfileViewController.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 28/05/2021.
//

import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var bottomAlignCS: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var countCharacterLeftLabel: UILabel!
    
    // MARK: - DataSource.
    var keyboardHeight: CGFloat = 0.0
    var contentTextView: String?
    var maxCharacter: Int = 100
    var field: String = ""
    var delegate: ReloadDataOfViewController?
    
    // MARK: - Init method.
    /// init()
    public class func instantiate(title: String?, delegate: ReloadDataOfViewController?, contentText: String?, maxCharacter: Int, field: String) -> EditProfileViewController {
        let vc = EditProfileViewController()
        vc.title = title
        vc.delegate = delegate
        vc.contentTextView = contentText
        vc.maxCharacter = maxCharacter
        vc.field = field
        return vc
    }
    
    // MARK: - Set up NavigationBar.
    func setUpButtonItemNavigationBar() {
        let rightBarItem: UIBarButtonItem = {
            let bt = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(rightBarItemAction))
            return bt
        }()
        navigationItem.rightBarButtonItem = rightBarItem
    }
    
    @objc func rightBarItemAction() {
        print("Right bar button was pressed!")
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        do {
            try updateAuthUserProfile()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Request.
    /// Update NoSQL data at server.
    func updateAuthUserProfile() throws {
        let updateAuthUserProfile = UpdateAuthUserProfile(data: textView.text, field: field)
        guard let userObjectId = Auth.userProfileData?._id
        else {
            return
        }
        let updateAuthUserrNoSQLRequest = ResourceRequest<UpdateAuthUserProfile, UpdateAuthUserProfile>(resourcePath: "users/editprofile/nosql/\(userObjectId)")
        updateAuthUserrNoSQLRequest.put(token: true, updateAuthUserProfile) { result in
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
            switch result {
            case .success:
                SoundFeedBack.success()
                DispatchQueue.main.async {
                    self.navigationItem.rightBarButtonItem?.tintColor = .systemGreen
                    self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "checkmark.circle.fill")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.navigationItem.rightBarButtonItem?.tintColor = .link
                    self.navigationItem.rightBarButtonItem?.image = nil
                    self.navigationItem.rightBarButtonItem?.title = "Save"
                    self.delegate?.refreshDataOfViewController()
                    self.navigationController?.popViewController(animated: true)
                }
                break
            case .failure:
                SoundFeedBack.fail()
                DispatchQueue.main.async {
                    self.navigationItem.rightBarButtonItem?.tintColor = .systemPink
                    self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "xmark.circle.fill")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.navigationItem.rightBarButtonItem?.tintColor = .link
                    self.navigationItem.rightBarButtonItem?.image = nil
                    self.navigationItem.rightBarButtonItem?.title = "Save"
                }
                break
            }
        }
    }

    
    
    // MARK: - Life cycle.
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        navigationItem.largeTitleDisplayMode = .never
        
        setUpTextView()
        setUpButtonItemNavigationBar()
        titleLabel.text = title
        textView.becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        textView.text = contentTextView
        self.countCharacterLeftLabel.text = "\(maxCharacter - textView.text.count)"
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

// MARK: - Extension.
extension EditProfileViewController: UITextViewDelegate {
    func setUpTextView() {
        textView.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
    }
    
    // Use this if you have a UITextView
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""

        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

        // make sure the result is under 16 characters
        self.countCharacterLeftLabel.text = updatedText.count <= maxCharacter ? "\(maxCharacter - updatedText.count)" : self.countCharacterLeftLabel.text
        return updatedText.count <= maxCharacter
    }
}

// MARK: - Keyboard.
extension EditProfileViewController: UITextFieldDelegate {
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardRect.height
            self.bottomAlignCS.constant = keyboardHeight
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.bottomAlignCS.constant = 0
        self.view.layoutIfNeeded()
    }
}

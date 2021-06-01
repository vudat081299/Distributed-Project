//
//  ProfileViewController.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 10/04/2021.
//

import UIKit

// MARK: - Protocol.
protocol ReloadDataOfViewController {
    func refreshDataOfViewController()
}

class ProfileViewController: UIViewController {
    

    @IBOutlet weak var tableView: UITableView!
    let imagePicker = UIImagePickerController()
    
    // MARK: - DataSource.
//    var avatar: UIImage? = Auth.avatar ?? nil {
//        didSet {
//            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
//        }
//    }
    var avatar: UIImage? = Auth.avatar ?? nil
    var authUser: User? = Auth.userProfileData ?? nil
    var userProfileDataInArray = [String?]() {
        didSet {
            tableView.reloadData()
        }
    }
    let listTitleLabel = [
        "Avatar",
        "User ID",
        "Name",
        "Last name",
        "Username",
        "Gmail",
        "Phone",
        "Bio"
    ]
    let uneditableRow = [0, 1, 4]
    let listPredictCharacterForTerm = [
        0,
        24,
        30,
        30,
        30,
        50,
        15,
        270
    ]
    
    /// Map to server key when post to server.
    let editField = [
        "defaultAvartar",
        "",
        "name",
        "lastName",
        "username",
        "personalData.email",
        "personalData.phoneNumber",
        "bio"
    ]
    
    // MARK: - Set up NavigationBar.
    func setUpButtonItemNavigationBar() {
        let rightBarItem: UIBarButtonItem = {
            let bt = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(rightBarItemAction))
            return bt
        }()
        let leftBarItem: UIBarButtonItem = {
            let bt = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(leftBarItemAction))
            return bt
        }()
        navigationItem.rightBarButtonItem = rightBarItem
        navigationItem.leftBarButtonItem = leftBarItem
        navigationItem.leftBarButtonItem?.tintColor = .systemPink
    }
    
    @objc func rightBarItemAction() {
        print("Right bar button was pressed!")
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        updateAuthUserAvatar()
    }
    
    @objc func leftBarItemAction() {
        print("Right bar button was pressed!")
        Auth.logout(on: self)
    }
    
    // MARK: - Request.
    /// Update avatar at server.
    func updateAuthUserAvatar() {
        if avatar != nil {
            guard let userObjectId = authUser?._id
            else {
                return
            }
            let fileUploadData = FileUpload(file: avatar!.pngData())
            let updateAvatarRequest = ResourceRequest<FileUpload, FileUpload>(resourcePath: "users/updateavatar/\(userObjectId)")
            updateAvatarRequest.put(token: true, fileUploadData) { result in
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
                    }
                    Auth.prepareUserProfileData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                        guard let self = self
                        else {
                            return
                        }
                        self.refreshData()
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
    }
    
    // MARK: - Life cycle.
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupTableView()
        setUpImagePicker()
        setUpButtonItemNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
//        self.refreshData()
        Auth.prepareUserProfileData() { [weak self] avatar, userProfileData in
            if let self = self {
                DispatchQueue.main.async {
                    self.authUser = userProfileData
                    self.prepareUserDataInArray()
                    print(userProfileData)
                    self.avatar = avatar
                }
            }
        }
    }
    
    func refreshData() {
        avatar = Auth.avatar
        authUser = Auth.userProfileData
        prepareUserDataInArray()
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Methods.
    func prepareUserDataInArray() {
        if let user = authUser {
            userProfileDataInArray = [
                user.profilePicture ?? "\(user.defaultAvartar!)",
                user._id,
                user.name,
                user.lastName,
                user.username,
                user.personalData.email,
                user.personalData.phoneNumber,
                user.bio,
            ]
        }
    }
}

// MARK: - Extension.
extension ProfileViewController: ReloadDataOfViewController {
    func refreshDataOfViewController() {
        self.refreshData()
    }
}
extension ProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func setUpImagePicker() {
        imagePicker.delegate = self
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            avatar = pickedImage
        }
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Table view.
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func setupTableView() {
        tableView.register(UINib(nibName: AvatarViewerAndPickerTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: AvatarViewerAndPickerTableViewCell.reuseIdentifier)
        tableView.register(UINib(nibName: ProfileInfoDataTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: ProfileInfoDataTableViewCell.reuseIdentifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userProfileDataInArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: AvatarViewerAndPickerTableViewCell.reuseIdentifier) as! AvatarViewerAndPickerTableViewCell
            cell.avatar.image = avatar
            cell.changeProfilePhotoClosure = {
                FeedBackTapEngine.tapped(style: .medium)
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileInfoDataTableViewCell.reuseIdentifier) as! ProfileInfoDataTableViewCell
            
            cell.tilteLabel.text = listTitleLabel[indexPath.row]
            cell.detailLabel.text = userProfileDataInArray[indexPath.row]
            
            if indexPath.row == userProfileDataInArray.count - 1 {
                cell.detailLabel.font = UIFont.systemFont(ofSize: 11.0)
                cell.separator.isHidden = true
                return cell
            }
            
            if uneditableRow.contains(indexPath.row) {
                cell.detailLabel.textColor = .secondaryLabel
            } else {
                cell.detailLabel.textColor = .label
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if uneditableRow.contains(indexPath.row) {
            return
        } else {
            let vc = EditProfileViewController.instantiate(title: listTitleLabel[indexPath.row], delegate: self, contentText: userProfileDataInArray[indexPath.row], maxCharacter: listPredictCharacterForTerm[indexPath.row], field: editField[indexPath.row])
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

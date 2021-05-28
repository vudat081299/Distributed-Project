//
//  ProfileViewController.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 10/04/2021.
//

import UIKit


class ProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let imagePicker = UIImagePickerController()
    var avatar: UIImage = Auth.avatar
    
    var authUser: User? = Auth.userProfileData
    var userProfileDataInArray = [String?]()
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
    let uneditableRow = [1]
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
    
    // MARK: - Life cycle.
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupTableView()
        setUpImagePicker()
        
        do {
            try passUserDataIntoArray()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func passUserDataIntoArray() throws {
        if let user = authUser {
            userProfileDataInArray = [
                user.profilePicture ?? "\(user.defaultAvartar!)",
                user._id,
                user.lastName,
                user.name,
                user.username,
                user.personalData.email,
                user.personalData.phoneNumber,
                user.bio,
            ]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
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



extension ProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func setUpImagePicker() {
        imagePicker.delegate = self
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            avatar = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
}



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
                tapped(style: .medium)
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
            
            let vc = EditProfileViewController.instantiate(title: listTitleLabel[indexPath.row], contentText: userProfileDataInArray[indexPath.row], maxCharacter: listPredictCharacterForTerm[indexPath.row], field: editField[indexPath.row])
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

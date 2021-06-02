//
//  UserAccessControlViewController.swift
//  MyMapKit
//
//  Created by Vũ Quý Đạt  on 17/12/2020.
//

import UIKit

enum GenderPicker: String, CaseIterable, Codable {
    case Male, Female, Other
    
    static var listRawValueString: [String] {
        var list = [String]()
        for item in self.allCases {
            list.append("\(item.rawValue)")
        }
        return list
    }
}
enum JobOrMajorPicker: String, CaseIterable, Codable {
    case None, Engineer, Pianist, Student, Teacher, Saler
    
    static var listRawValueString: [String] {
        var list = [String]()
        for item in self.allCases {
            list.append("\(item.rawValue)")
        }
        return list
    }
}

protocol PassInputDataFromCell {
    func pass(_ string: String, at field: IndexPath)
}

class SignUpViewController: UIViewController, UIScrollViewDelegate, PassInputDataFromCell {
    func pass(_ string: String, at field: IndexPath) {
        signUpUserListVar[keyOnPostAPI[field.section][field.row]] = string
        inputData[field.section][field.row] = string
    }
    
    
    
    // MARK: - IBOutlet.
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomCS: NSLayoutConstraint!
    
    // MARK: - Variables.
    var keyboardHeight: CGFloat = 0.0
    var signUpUserPost: SignUpUserPost!
    var signUpUserListVar: [String: String] = [:]
    
    
    enum InputType: Int {
        case text, number, pickerGender, datePicker, pickerJobOrMajor
    }
    
    // MARK: - Data tableView.
    let rowData = [
        ["Name",
         "Last name",
         "Username",
         "Password"],
        ["Gender",
         "Phonenumber",
         "Email",
         "Dob",
         "City",
         "Country",
         "Job or Major",
         "Bio"]
    ]
    let placeHoldersRow = [
        ["Required",
         "Optional",
         "Required",
         "Required"],
        ["",
         "Optional",
         "Optional",
         "",
         "Optional",
         "Optional",
         "",
         "Optional"]
    ]
    let typeInputOfRow: [[InputType]] = [
        [.text,
         .text,
         .text,
         .text],
        [.pickerGender,
         .number,
         .text,
         .datePicker,
         .text,
         .text,
         .pickerJobOrMajor,
         .text]
    ]
    let header = [
        "Create your account", "About you"
    ]
    var inputData = [
        ["",
         "",
         "",
         ""],
        ["",
         "",
         "",
         "",
         "",
         "",
         "",
         ""]
    ]
    let keyOnPostAPI = [
        ["name",
         "lastName",
         "username",
         "password"],
        ["gender",
         "phoneNumber",
         "email",
         "dob",
         "city",
         "country",
         "defaultAvartar",
         "bio"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign up"
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.sizeToFit()
        navigationItem.largeTitleDisplayMode = .always
        
        // Do any additional setup after loading the view.
        configureHierarchy()
        let notificationCenter = NotificationCenter.default
//        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        setUpNavigationBar()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func rightBarItemAction() {
        print("Right bar button was pressed!")
        let request = ResourceRequest<SignUpUserPost, SignUpUserPost>(resourcePath: "users/signup")
        if (signUpUserListVar["name"] == nil ||
                signUpUserListVar["username"] == nil ||
                signUpUserListVar["password"] == nil
        ) {
            return
        } else {
        }
        let data = SignUpUserPost(name: signUpUserListVar["name"]!,
                                        lastName: signUpUserListVar["lastName"],
                                        username: signUpUserListVar["username"]!,
                                        password: signUpUserListVar["password"]!,
                                        gender: Gender(rawValue: Int(signUpUserListVar["gender"] ?? "\(Gender.other.rawValue)")!),
                                        phoneNumber: signUpUserListVar["phoneNumber"],
                                        email: signUpUserListVar["email"],
                                        dob: signUpUserListVar["dob"],
                                        city: signUpUserListVar["city"],
                                        country: signUpUserListVar["country"],
                                        defaultAvartar: DefaultAvartar(rawValue: Int(signUpUserListVar["defaultAvartar"] ?? "\(DefaultAvartar.other.rawValue)")!),
                                        bio: signUpUserListVar["bio"],
                                        idDevice: signUpUserListVar["idDevice"]
        )
        request.post(data) { result in
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
                    self.navigationItem.rightBarButtonItem?.title = "Regist"
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
                    self.navigationItem.rightBarButtonItem?.title = "Regist"
                }
                break
            }
        }
    }
    
    func setUpNavigationBar() {
        navigationItem.title = "Regist Account"
        // BarButtonItem.
        let rightBarItem: UIBarButtonItem = {
            let bt = UIBarButtonItem(title: "Regist", style: .plain, target: self, action: #selector(rightBarItemAction))
            return bt
        }()
        navigationItem.rightBarButtonItem = rightBarItem
    }
    
}



// MARK: - TableView.
extension SignUpViewController: UITableViewDataSource, UITableViewDelegate {
    
    private func configureHierarchy() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: SignupInputTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: SignupInputTableViewCell.reuseIdentifier)
        tableView.register(UINib(nibName: SignupPickerInputTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: SignupPickerInputTableViewCell.reuseIdentifier)
        tableView.register(UINib(nibName: SignupDatePickerInputTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: SignupDatePickerInputTableViewCell.reuseIdentifier)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return header.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowData[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return header[section]
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 350
        } else {
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch typeInputOfRow[indexPath.section][indexPath.row] {
        case .text:
            let cell = tableView.dequeueReusableCell(withIdentifier: SignupInputTableViewCell.reuseIdentifier, for: indexPath) as! SignupInputTableViewCell
            cell.contentLabel.text = rowData[indexPath.section][indexPath.row]
            if indexPath == IndexPath(row: 3, section: 0) {
                cell.content.isSecureTextEntry = true
            } else {
                cell.content.isSecureTextEntry = false
            }
            if indexPath == IndexPath(row: 0, section: 0) {
                cell.content.becomeFirstResponder()
            } else {
                
            }
            cell.delegate = self
            cell.indexPath = indexPath
            cell.content.text = inputData[indexPath.section][indexPath.row]
            cell.content.placeholder = placeHoldersRow[indexPath.section][indexPath.row]
            return cell
        case .number:
            let cell = tableView.dequeueReusableCell(withIdentifier: SignupInputTableViewCell.reuseIdentifier, for: indexPath) as! SignupInputTableViewCell
            cell.contentLabel.text = rowData[indexPath.section][indexPath.row]
            cell.content.placeholder = placeHoldersRow[indexPath.section][indexPath.row]
            cell.content.text = inputData[indexPath.section][indexPath.row]
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        case .pickerGender:
            let cell = tableView.dequeueReusableCell(withIdentifier: SignupPickerInputTableViewCell.reuseIdentifier, for: indexPath) as! SignupPickerInputTableViewCell
            cell.itemsOfPickerView = GenderPicker.listRawValueString
            cell.contentLabel.text = rowData[indexPath.section][indexPath.row]
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        case .pickerJobOrMajor:
            let cell = tableView.dequeueReusableCell(withIdentifier: SignupPickerInputTableViewCell.reuseIdentifier, for: indexPath) as! SignupPickerInputTableViewCell
            cell.itemsOfPickerView = JobOrMajorPicker.listRawValueString
            cell.contentLabel.text = rowData[indexPath.section][indexPath.row]
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        case .datePicker:
            let cell = tableView.dequeueReusableCell(withIdentifier: SignupDatePickerInputTableViewCell.reuseIdentifier, for: indexPath) as! SignupDatePickerInputTableViewCell
            cell.contentLabel.text = rowData[indexPath.section][indexPath.row]
            cell.delegate = self
            cell.indexPath = indexPath
//            cell.itemsOfPickerView = GenderPicker
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch typeInputOfRow[indexPath.section][indexPath.row] {
        case .text, .number:
            return 44
        default:
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}




//MARK: Keyboard.
extension SignUpViewController: UITextFieldDelegate {
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardRect.height
            self.tableViewBottomCS.constant = keyboardHeight
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardRect.height
            self.tableViewBottomCS.constant = 0
            self.view.layoutIfNeeded()
        }
    }
}

////
////  SignUpViewController.swift
////  Social Messaging
////
////  Created by Vũ Quý Đạt  on 18/05/2021.
////
//
//import UIKit
//
//class SignUpViewController: UIViewController {
//    
//    // MARK: - IBOutlet.
//    @IBOutlet weak var tableView: UITableView!
//
//    
//    
//    // MARK: - Data structure.
//    enum SectionType: Int, CaseIterable {
//        case list, collection
//    }
//    
//    class CellItem: Hashable {
//        let image: UIImage?
//        let data: (String?, String?) // (label, detaiLabel)
//        let select: (() -> Void)? // select cell
//        let cellClass: UITableViewCell // class of cell
//        let viewControllerType: UIViewController.Type? // view show when select cell
//        
//        init(image: UIImage? = nil,
//             data: (String?, String?) = (nil, nil),
//             select: (() -> ())? = nil,
//             cellClass: UITableViewCell = UITableViewCell(),
//             viewControllerType: UIViewController.Type? = nil
//        ) {
//            self.image = image
//            self.data = data
//            self.select = select
//            self.cellClass = cellClass
//            self.viewControllerType = viewControllerType
//        }
//        
//        func hash(into hasher: inout Hasher) {
//            hasher.combine(identifier)
//        }
//        static func == (lhs: CellItem, rhs: CellItem) -> Bool {
//            return lhs.identifier == rhs.identifier
//        }
//        private let identifier = UUID()
//    }
//    
//    class SectionItem {
//        let cell: [CellItem]
//        let sectionType: SectionType?
//        let supplementaryData: (String?, String?)
//        let header: UICollectionReusableView?
//        let footer: UICollectionReusableView?
//        
//        init(cell: [CellItem],
//             sectionType: SectionType? = .list,
//             supplementaryData: (String?, String?) = (nil, nil),
//             header: UICollectionReusableView? = nil,
//             footer: UICollectionReusableView? = nil
//        ) {
//            self.cell = cell
//            self.sectionType = sectionType
//            self.behavior = behavior
//            self.supplementaryData = supplementaryData
//            self.header = header
//            self.footer = footer
//        }
//    }
//    
//    
//    // MARK: - TableView Data.
//    let data = [[""]]
//
//    
//    
//    // MARK: - Life cycle.
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//    }
//    
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//    
//}
//
//// MARK: - TableView.
//extension SignUpViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        <#code#>
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        <#code#>
//    }
//}
//
//
//
//

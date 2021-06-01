//
//  MessagingViewControllerTableView.swift
//  Social Messaging
//
//  Created by Dat vu on 13/05/2021.
//

import UIKit
import CryptoKit

func MD5<T: Encodable>(_ data: T) -> String {
    do {
        let encodedData = try JSONEncoder().encode(data)
        let digest = Insecure.MD5.hash(data: encodedData)
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    } catch {
        print("Cannot md5 object!")
        return "error: true"
    }
}

class MessagingViewControllerTableView: UIViewController, MessagePullThread, MessagePushThread {
    
    private var tableView: UITableView! = nil
    var messagePullThreadDelegate: MessagePullThread?
    var messagePushThreadDelegate: MessagePushThread?
    var userBoxData: [ResolvedBox] = Auth.userBoxData
    let authUser: User? = Auth.userProfileData
    
    
    
    // MARK: - Navbar components.
    let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "New Search"
        searchController.searchBar.searchBarStyle = .minimal
//        searchController.dimsBackgroundDuringPresentation = false // was deprecated in iOS 12.0
        searchController.definesPresentationContext = true
       return searchController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.searchController = searchController
        configureHierarchy()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if MD5(userBoxData) != MD5(Auth.userBoxData) || userBoxData.count != Auth.userBoxData.count {
//            userBoxData = Auth.userBoxData
//            self.tableView.reloadData()
//        }
        fetchBoxesData {
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
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
    
    func fetchBoxesData(completion: @escaping () -> Void) {
        guard let userObjectId = authUser?._id
        else {
            return
        }
        let request_box = ResourceRequest<ResolvedBox, ResolvedBox>(resourcePath: "messaging/boxes/data/\(userObjectId)")
        request_box.getArray(token: true) { result in
            switch result {
            case .success(let data):
                let boxData = data.sorted(by: { $0.boxSpecification.lastestUpdate > $1.boxSpecification.lastestUpdate })
                Auth.userBoxData = boxData
                self.userBoxData = boxData
                completion()
            case .failure:
                break
            }
        }
    }
    
    func receiveMessage(data: WSMessage) {
        messagePullThreadDelegate?.receiveMessage(data: data)
    }
    
    func sendMessage(data: MessageSendWS) {
        messagePushThreadDelegate?.sendMessage(data: data)
    }
}



// MARK: - TableView
extension MessagingViewControllerTableView: UITableViewDelegate, UITableViewDataSource {
    private func configureHierarchy() {
        tableView = UITableView(frame: view.bounds)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: BoxTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: BoxTableViewCell.reuseIdentifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userBoxData.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BoxTableViewCell.reuseIdentifier, for: indexPath) as! BoxTableViewCell
//        cell.boxImage
        let box = userBoxData[indexPath.row]
        if let authUser = Auth.userProfileData, box.type == .privateChat {
            for (index, name) in box.membersName.enumerated() {
                if name != authUser.name {
                    cell.name.text = name
                    break
                } else if (index == box.membersName.count - 1) {
                    cell.name.text = authUser.name
                    break
                }
            }
            for (index, userObjectId) in box.members_id.enumerated() {
                if userObjectId != authUser._id {
                    if let image = cacheImages[userObjectId] {
                        cell.boxImage.image = image
                    } else {
                        let imageURL = "\(basedURL)users/getavatarwithuserobjectid/\(userObjectId)" // Constant.
                        DispatchQueue(label: "com.chat.getavatar.qos").async(qos: .userInitiated) {
                            if let image = imageURL.getImageWithThisURL() {
                                DispatchQueue.main.async {
                                    cell.boxImage.image = image
                                    cacheImages[userObjectId] = image
                                }
                            } else {
                                DispatchQueue.main.async {
                                    cell.boxImage.image = UIImage(named: "avatar_7")
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
        
        
        cell.idLabel.text = "@\(box._id)"
        cell.lastestMess.text = box.boxSpecification.lastestMess
//        let dateFormatter = ISO8601DateFormatter()
//        var dateString = ""
//        if box.boxSpecification.lastestUpdate.count > 20, let range = box.boxSpecification.lastestUpdate.range(of: " ") {
//            let substring = box.boxSpecification.lastestUpdate.index(range.upperBound, offsetBy: 5)
//            let date = box.boxSpecification.lastestUpdate[range.lowerBound..<substring]
//            dateString = String(date)
//        }
        cell.timeStampButton.setTitle(box.boxSpecification.lastestUpdate.transformToShortTime(), for: .normal)
        return cell
    }
    
    func getAvatar(for cell: BoxTableViewCell, of userObjectId: String) {
        if let image = cacheImages[userObjectId] {
            cell.boxImage.image = image
        } else {
            let imageURL = "\(basedURL)users/getavatarwithuserobjectid/\(userObjectId)" // Constant.
            DispatchQueue(label: "com.chat.getavatar.qos").async(qos: .userInitiated) {
                if let image = imageURL.getImageWithThisURL() {
                    DispatchQueue.main.async {
                        cell.boxImage.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.boxImage.image = UIImage(named: "avatar_7")
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let chattingViewController = ChattingViewController()
        messagePullThreadDelegate = chattingViewController
        let box = userBoxData[indexPath.row]
        chattingViewController.boxObjectId = box._id
        chattingViewController.boxData = box
        chattingViewController.delegate = self
        if box.type == .privateChat {
            chattingViewController.title = box.membersName.first(where: { $0 != Auth.userProfileData?.name })
        } else {
            chattingViewController.title = "Group" 
        }
        chattingViewController.navigationItem.largeTitleDisplayMode = .never
        chattingViewController.tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(chattingViewController, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
}

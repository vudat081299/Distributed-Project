//
//  MessagingViewControllerTableView.swift
//  Social Messaging
//
//  Created by Dat vu on 13/05/2021.
//

import UIKit


var userBoxData: [ResolvedBox] = []

class MessagingViewControllerTableView: UIViewController, MessagePullThread, MessagePushThread {
    
    private var tableView: UITableView! = nil
    var messagePullThreadDelegate: MessagePullThread?
    var messagePushThreadDelegate: MessagePushThread?
    
    
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
        let request_box = ResourceRequest<ResolvedBox>(resourcePath: "messaging/boxes/data/\(Auth.userProfileData!._id!)")
        request_box.getArray(token: Auth.token) { result in
            switch result {
            case .success(let data):
                let boxData = data.sorted(by: { $0.boxSpecification.lastestUpdate > $1.boxSpecification.lastestUpdate })
                Auth.userBoxData = boxData
                userBoxData = boxData
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
        let authUser = Auth.userProfileData
        if box.type == .privateChat {
            for name in box.membersName {
                if name != authUser?.name {
                    cell.name.text = name
                    break
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let chattingViewController = ChattingViewController()
        messagePullThreadDelegate = chattingViewController
        let box = userBoxData[indexPath.row]
        chattingViewController.boxObjectId = box._id
        chattingViewController.boxData = userBoxData[indexPath.row]
        chattingViewController.delegate = self
        chattingViewController.navigationItem.largeTitleDisplayMode = .never
        chattingViewController.tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(chattingViewController, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
}

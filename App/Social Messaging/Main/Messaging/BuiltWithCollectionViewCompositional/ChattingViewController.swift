//
//  ChatViewController.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 21/04/2021.
//

import UIKit

var messages: [String: [ResolvedMessage]] = [:] // map with box id.

class ChattingViewController: UIViewController, MessagePullThread, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    // MARK: - CV config data.
    // Collection view config data.
    static let sectionHeaderElementKind = "section-header-element-kind"
    static let sectionFooterElementKind = "section-footer-element-kind"

    /// Datasource of main collectionview (chat content view).
    var dataSource: UICollectionViewDiffableDataSource<Int, Int>! = nil
    
    
    
    // MARK: - UI.
//    var chatView: UICollectionView! = nil
    let imagePicker = UIImagePickerController()
    
    
    
    // MARK: - IBOutlet.
    // Views.
    @IBOutlet weak var containChattingView: UIView!
    @IBOutlet weak var sendingImageViewContainer: UIView!
    
    @IBOutlet weak var chatView: UICollectionView!
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var sendingImage: UIImageView!
    @IBOutlet weak var removeSendingImageButton: UIButton!
    // Constraints.
    @IBOutlet weak var textFieldBottomAlign: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingOfTextFieldCS: NSLayoutConstraint!
    
    
    
    // MARK: - Variables.
    var keyboardHeight: CGFloat = 0.0
    var headersIndex = [IndexPath]()
    var touchPosition: CGPoint = CGPoint(x: 0, y: 0)
    var boxObjectId: String = ""
    var boxData: ResolvedBox!
    var messagesOfBox: [ResolvedMessage] = []
    let authUser = Auth.userProfileData
    var delegate: MessagePushThread?
    var users: [String: User] = [:]
    
    
    
    // MARK: - Closures.
    private lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureOnTable(_:)))
        gesture.delegate = self
        gesture.cancelsTouchesInView = true
        return gesture
    }()
    
    
    
    // MARK: - Set up methods.
    func setUpNavigationBar() {
        navigationItem.title = "Pinned"
        // BarButtonItem.
        let rightBarItem: UIBarButtonItem = {
            let bt = UIBarButtonItem(image: UIImage(systemName: "video.circle.fill"), style: .plain, target: self, action: #selector(rightBarItemAction))
            return bt
        }()
        navigationItem.rightBarButtonItem = rightBarItem
    }
    
    @objc func rightBarItemAction() {
        print("Right bar button was pressed!")
        self.present(buildMainViewController(), animated: true)
    }
    
    
    
    // MARK: - Video call setup.
    private let config = Config.default
    private func buildMainViewController() -> UIViewController {
        let ws = WebSocketSM("ws://\(ip)/connecttowsserver/\(Auth.userId ?? "")")
        ws.close()
        let webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers)
        let signalClient = self.buildSignalingClient()
        let mainViewController = MainViewController(signalClient: signalClient, webRTCClient: webRTCClient)
        let navViewController = UINavigationController(rootViewController: mainViewController)
        if #available(iOS 11.0, *) {
            navViewController.navigationBar.prefersLargeTitles = true
        }
        else {
            navViewController.navigationBar.isTranslucent = false
        }
        return navViewController
    }
    
    private func buildSignalingClient() -> SignalingClient {
        
        // iOS 13 has native websocket support. For iOS 12 or lower we will use 3rd party library.
        let webSocketProvider: WebSocketProvider
        
        if #available(iOS 13.0, *) {
            webSocketProvider = NativeWebSocket(url: self.config.signalingServerUrl)
        } else {
            webSocketProvider = StarscreamWebSocket(url: self.config.signalingServerUrl)
        }
        
        return SignalingClient(webSocket: webSocketProvider)
    }
    
    
    
    // MARK: - Life cycle.
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpNavigationBar()
        configureHierarchy()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        imagePicker.delegate = self
        self.view.sendSubviewToBack(sendingImage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        fetchBoxesData {
//            self.configureDataSource()
            DispatchQueue.main.async {
                self.configureDataSource()
                self.chatView.scrollToItem(at: IndexPath(row: 0, section: self.messagesOfBox.count - 1), at: .bottom, animated: true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
    
    
    // MARK: - Methods
    func receiveMessage(data: WSMessage) {
        let message = ResolvedMessage(_id: data._id, creationDate: data.creationDate, text: data.text, boxId: data.boxId!, fileId: data.fileId, type: data.type.rawValue, senderId: data.senderId!, senderIdOnRDBMS: data.senderIdOnRDBMS!)
        messagesOfBox.append(message)
//        chatView.insertItems(at: [IndexPath(row: 0, section: <#T##Int#>)])
//        chatView.insertSections(IndexSet()
        setUpDataSource()
    }
    
    func fetchBoxesData(completion: @escaping () -> Void) {
        let request_mess = ResourceRequest<ResolvedMessage>(resourcePath: "messaging/data/\(boxObjectId)")
        request_mess.getArray(token: Auth.token) { result in
            switch result {
            case .success(let data):
                let sortMessages = data.sorted(by: { $0.creationDate < $1.creationDate })
                if sortMessages.count > 0 {
                    if messages[sortMessages[0].boxId] != nil {
                        (messages[sortMessages[0].boxId])! = sortMessages
                    } else {
                        messages[sortMessages[0].boxId] = []
                        (messages[sortMessages[0].boxId])! = sortMessages
                    }
                    if messages[self.boxObjectId] != nil {
                        self.messagesOfBox = messages[self.boxObjectId]!
                    }
                }
                completion()
            case .failure:
                break
            }
        }
    }

//    func fetchFriendData(completion: @escaping () -> Void) {
//        let request_mess = ResourceRequest<User>(resourcePath: "mess/messesinbox/\(boxId)")
//        request_mess.getArray(token: Auth.token) { result in
//            switch result {
//            case .success(let data):
//                let sortMessages = data.sorted(by: { $0.creationDate < $1.creationDate })
//                if sortMessages.count > 0 {
//                    if messages[sortMessages[0].boxId] != nil {
//                        (messages[sortMessages[0].boxId])! = sortMessages
//                    } else {
//                        messages[sortMessages[0].boxId] = []
//                        (messages[sortMessages[0].boxId])! = sortMessages
//                    }
//                    if messages[self.boxId] != nil {
//                        self.messagesOfBox = messages[self.boxId]!
//                    }
//                }
//                completion()
//            case .failure:
//                break
//            }
//        }
//    }
    
    // MARK: - Delegate methods.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            sendingImage.contentMode = .scaleAspectFit
            sendingImage.image = pickedImage
            self.view.bringSubviewToFront(sendingImageViewContainer)
        }

        dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - IBAction
    @IBAction func sendMessage(_ sender: UIButton) {
//        push
        let majorData = MajorDataSendWS(boxId: boxData._id,
                                        creationDate: Time.iso8601String,
                                        text: chatTextField.text,
                                        fileId: nil,
                                        type: .text,
                                        senderId: Auth.userProfileData!._id!,
                                        senderIdOnRDBMS: Auth.userProfileData!.idOnRDBMS!,
                                        members: boxData.members_id
        )
        let data = MessageSendWS(type: .newMess, majorData: majorData)
//        delegate?.sendMessage(data: data)
        
        let request = ResourceRequest<MessageSendWS>(resourcePath: "messaging/send/mess")
        request.post(token: Auth.token, data) { result in
            switch result {
            case .success(let data):
                break
            case .failure:
                break
            }
        }
    }
    @IBAction func pickImage(_ sender: UIButton) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func removeSendingImageAction(_ sender: UIButton) {
        sendingImage.image = nil
        self.view.sendSubviewToBack(sendingImageViewContainer)
    }
    

    // MARK: - Gesture.
    /// Pan Gesture on collection chat view. Using for swipe showing time stamp.
    @objc func panGestureOnTable(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: chatView)
        if sender.state == .ended {
            chatView.visibleCells.forEach {
                if let cell = $0 as? FirstMessContentCellForSection {
                    UIView.animate(withDuration: 0.3, delay: 0.03,
                                   options: [.curveEaseOut],
                                   animations: { [weak self] in
                                    cell.constraint.constant = 0
                                    self?.view.layoutIfNeeded()
                                   }, completion: nil)
                }
                if let cell = $0 as? MessContentCell {
                    UIView.animate(withDuration: 0.3, delay: 0.03,
                                   options: [.curveEaseOut],
                                   animations: { [weak self] in
                                    cell.constraint.constant = 0
                                    self?.view.layoutIfNeeded()
                                   }, completion: nil)
                }
            }
            chatView.visibleSupplementaryViews(ofKind: ChattingViewController.sectionHeaderElementKind).forEach {
                if let cell = $0 as? HeaderSessionChat {
                    UIView.animate(withDuration: 0.3, delay: 0.03,
                                   options: [.curveEaseOut],
                                   animations: { [weak self] in
                                    cell.constraint.constant = 0
                                    self?.view.layoutIfNeeded()
                                   }, completion: nil)
                }
            }
        } else if sender.state == .began {
            touchPosition = touchPoint
        } else if sender.state == .changed {
            chatView.visibleCells.forEach {
                if let cell = $0 as? FirstMessContentCellForSection {
                    cell.constraint.constant = (touchPosition.x - touchPoint.x) < 75 ? ((touchPosition.x - touchPoint.x) > 0 ? (touchPosition.x - touchPoint.x) : 0) : 75
                }
                if let cell = $0 as? MessContentCell {
                    cell.constraint.constant = (touchPosition.x - touchPoint.x) < 75 ? ((touchPosition.x - touchPoint.x) > 0 ? (touchPosition.x - touchPoint.x) : 0) : 75
                }
            }
            chatView.visibleSupplementaryViews(ofKind: ChattingViewController.sectionHeaderElementKind).forEach {
                if let cell = $0 as? HeaderSessionChat {
                    cell.constraint.constant = (touchPosition.x - touchPoint.x) < 75 ? ((touchPosition.x - touchPoint.x) > 0 ? (touchPosition.x - touchPoint.x) : 0) : 75
                }
            }
        }
    }
    
}



// MARK: - Extensions.
extension ChattingViewController {
    
    
    
    // MARK: - Layout for collection view.
    /// - Tag: PinnedHeader
    func createLayout() -> UICollectionViewLayout {
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 1
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(45)),
            elementKind: ChattingViewController.sectionHeaderElementKind,
            alignment: .top)
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(44)),
            elementKind: ChattingViewController.sectionFooterElementKind,
            alignment: .bottom)
        sectionHeader.pinToVisibleBounds = true
        sectionHeader.zIndex = 2
        section.boundarySupplementaryItems = [sectionHeader]

        let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)
        return layout
        
//        let config = UICollectionLayoutListConfiguration(appearance: .plain)
//        return UICollectionViewCompositionalLayout.list(using: config)
    }
}



extension ChattingViewController {
    
    
    
    // MARK: - Config collection view.
    func configureHierarchy() {
        
        // Work with infile collection view.
//        chatView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        // Work with xib collection view.
        chatView.frame = view.bounds
        chatView.collectionViewLayout = createLayout()
        
        chatView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        chatView.backgroundColor = .systemGray6
        view.addSubview(chatView)
        chatView.delegate = self
        chatView.register(UINib(nibName: MessContentCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: MessContentCell.reuseIdentifier)
        chatView.register(UINib(nibName: FirstMessContentCellForSection.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: FirstMessContentCellForSection.reuseIdentifier)
        chatView.register(UINib(nibName: HeaderSessionChat.reuseIdentifier, bundle: nil), forSupplementaryViewOfKind: ChattingViewController.sectionHeaderElementKind, withReuseIdentifier: HeaderSessionChat.reuseIdentifier)
        chatView.addGestureRecognizer(panGesture)
        view.bringSubviewToFront(containChattingView)
    }
    
    // MARK: - Config datasource.
    /// - Tag: PinnedHeaderRegistration
    func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration<MessContentCell, Int> { (cell, indexPath, identifier) in
            // Populate the cell with our item description.
            cell.contentTextLabel.text = "\(indexPath.section),\(indexPath.item)"
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration
        <HeaderSessionChat>(elementKind: ChattingViewController.sectionHeaderElementKind) {
            (supplementaryView, string, indexPath) in
//            supplementaryView.label.text = "\(string) for section \(indexPath.section)"
//            supplementaryView.backgroundColor = .lightGray
//            supplementaryView.layer.borderColor = UIColor.black.cgColor
//            supplementaryView.layer.borderWidth = 1.0
        }
        
//        let footerRegistration = UICollectionView.SupplementaryRegistration
//        <HeaderSessionChat>(elementKind: ChattingViewController.sectionFooterElementKind) {
//            (supplementaryView, string, indexPath) in
//            supplementaryView.label.text = "\(string) for section \(indexPath.section)"
//            supplementaryView.backgroundColor = .lightGray
//            supplementaryView.layer.borderColor = UIColor.black.cgColor
//            supplementaryView.layer.borderWidth = 1.0
//        }
            
        dataSource = UICollectionViewDiffableDataSource<Int, Int>(collectionView: chatView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
//            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
            if indexPath.row == 0 {
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: FirstMessContentCellForSection.reuseIdentifier,
                        for: indexPath) as? FirstMessContentCellForSection else { fatalError("Cannot create new cell") }
                let message = self.messagesOfBox[indexPath.section]
                
                if message.senderId == self.authUser?._id {
                    cell.senderName.text = self.authUser?.name
                    cell.senderName.textColor = .orange
                } else {
                    for (index, value) in self.boxData.membersName.enumerated() {
                        if value != self.authUser?.name {
                            cell.senderName.text = value
                        }
                    }
                    cell.senderName.textColor = .link
                }

//                cell.creationDate.text = Time.getTypeWithFormat(of: message.creationDate, type: .date)
                cell.creationDate.text = message.creationDate.iso8601String
                cell.contentTextLabel.text = message.text
                return cell
            }
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MessContentCell.reuseIdentifier,
                for: indexPath) as? MessContentCell else { fatalError("Cannot create new cell") }
//            cell.contentTextLabel.text = self.messagesOfBox[indexPath.row].text
            return cell
        }
        
        dataSource.supplementaryViewProvider = { (view, kind, index) in
//            return self.chatView.dequeueConfiguredReusableSupplementary(
//                using: kind == ChattingViewController.sectionHeaderElementKind ? headerRegistration : footerRegistration, for: index)
//            return self.chatView.dequeueConfiguredReusableSupplementary(
//                using: headerRegistration, for: index)
            
            guard let supplementaryView = view.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderSessionChat.reuseIdentifier, for: index) as? HeaderSessionChat else { fatalError("Cannot create new cell") }
            supplementaryView.avatar.image = UIImage(named: "avatar_11")
            supplementaryView.avatar.clipsToBounds = true
            supplementaryView.avatar.layer.cornerRadius = 8
            supplementaryView.clipsToBounds = false
            return supplementaryView
        }
        setUpDataSource()
    }
    
    func setUpDataSource() {
//        // initial data
        let itemsPerSection = 1
        var sections = Array(0..<0)
        if (messagesOfBox.count > 0) {
            sections = Array(0..<messagesOfBox.count)
        } else {
            let sections = Array(0..<0)
        }
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        var itemOffset = 0
        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems(Array(itemOffset..<itemOffset + itemsPerSection))
            itemOffset += itemsPerSection
        }
        dataSource.apply(snapshot, animatingDifferences: true)
        scrollToBottom(of: chatView)
        // initial data
//        let itemsPerSection = 5
//        let sections = Array(0..<5)
//        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
//        var itemOffset = 0
//        sections.forEach {
//            snapshot.appendSections([$0])
//            snapshot.appendItems(Array(itemOffset..<itemOffset + itemsPerSection))
//            itemOffset += itemsPerSection
//        }
//        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func scrollToBottom(of collectionView: UICollectionView) {
        chatView.scrollToItem(at: IndexPath(item: 0, section: messagesOfBox.count - 1), at: .bottom, animated: true)
        self.view.layoutIfNeeded()
    }
}



// MARK: - Select cells.
extension ChattingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.deselectItem(at: indexPath, animated: true)
    }
}



// MARK: - Config gesture recognizer.
extension ChattingViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return [gestureRecognizer, otherGestureRecognizer].contains(panGesture)
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gesture = gestureRecognizer as? UIPanGestureRecognizer, gesture == panGesture {
            let translation = gesture.translation(in: gesture.view)
            return (abs(translation.x) > abs(translation.y)) && (gesture == panGesture)
        }
        return true
    }
    
    @IBAction func hideKeyBoardTap(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
}



// MARK: - Keyboard.
extension ChattingViewController: UITextFieldDelegate {
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            leadingOfTextFieldCS.constant = 8
            keyboardHeight = keyboardRect.height
            self.bottomConstraint.constant = keyboardHeight
            self.view.layoutIfNeeded()
            scrollToBottom(of: chatView)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            leadingOfTextFieldCS.constant = 120
            keyboardHeight = keyboardRect.height
            self.bottomConstraint.constant = 0
            self.view.layoutIfNeeded()
            scrollToBottom(of: chatView)
        }
    }
}

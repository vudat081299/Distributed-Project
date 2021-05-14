//
//  ChatViewController.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 21/04/2021.
//

import UIKit

var messages: [String: [ResolvedMessage]] = [:] // map with box id.

class ChattingViewController: UIViewController {
    
    // MARK: - CV config data.
    // Collection view config data.
    static let sectionHeaderElementKind = "section-header-element-kind"
    static let sectionFooterElementKind = "section-footer-element-kind"

    /// Datasource of main collectionview (chat content view).
    var dataSource: UICollectionViewDiffableDataSource<Int, Int>! = nil
    
    
    
    // MARK: - UI.
//    var chatView: UICollectionView! = nil
    
    
    
    // MARK: - IBOutlet.
    // Views.
    @IBOutlet weak var containChattingView: UIView!

    @IBOutlet weak var chatView: UICollectionView!
    @IBOutlet weak var chatTextField: UITextField!
    // Constraints.
    @IBOutlet weak var textFieldBottomAlign: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    
    // MARK: - Variables.
    var keyboardHeight: CGFloat = 0.0
    var headersIndex = [IndexPath]()
    var touchPosition: CGPoint = CGPoint(x: 0, y: 0)
    var boxId: String = ""
    var messagesOfBox: [ResolvedMessage] = []
    
    
    // MARK: - Closures.
    private lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureOnTable(_:)))
        gesture.delegate = self
        gesture.cancelsTouchesInView = true
        return gesture
    }()
    
    
    
    // MARK: - Set up methods.
    @objc func rightBarItemAction() {
        print("Right bar button was pressed!")
    }
    
    func setUpNavigationBar() {
        
        navigationItem.title = "Pinned"
        
        // BarButtonItem.
        let rightBarItem: UIBarButtonItem = {
            let bt = UIBarButtonItem(image: UIImage(systemName: "video.circle.fill"), style: .plain, target: self, action: #selector(rightBarItemAction))
            return bt
        }()
        navigationItem.rightBarButtonItem = rightBarItem
    }
    
    
    
    // MARK: - Life cycle.
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fetchBoxesData {
            self.configureDataSource()
        }
        setUpNavigationBar()
        configureHierarchy()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
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
    
    func fetchBoxesData(completion: @escaping () -> Void) {
        let request_mess = ResourceRequest<ResolvedMessage>(resourcePath: "mess/\(boxId)")
        request_mess.getArray(token: Auth.token) { result in
            switch result {
            case .success(let data):
                data.forEach { message in
                    print(messages)
                    if messages[message.boxId] != nil {
                        (messages[message.boxId])!.append(message)
                    } else {
                        messages[message.boxId] = []
                        (messages[message.boxId])!.append(message)
                    }
                }
                if messages[self.boxId] != nil {
                    self.messagesOfBox = messages[self.boxId]!
                }
                completion()
            case .failure:
                break
            }
        }
    }
    
    
    
    // MARK: - IBAction
    @IBAction func sendMessage(_ sender: UIButton) {
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
                cell.senderName.text = self.messagesOfBox[indexPath.row].sender_id
                cell.creationDate.text = String(describing: self.messagesOfBox[indexPath.row].creationDate)
                return cell
            }
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MessContentCell.reuseIdentifier,
                for: indexPath) as? MessContentCell else { fatalError("Cannot create new cell") }
            cell.contentTextLabel.text = self.messagesOfBox[indexPath.row].text
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

        // initial data
        let itemsPerSection = 1
        var sections = Array(0..<0)
        if (messagesOfBox.count > 0) {
        sections = Array(0..<messagesOfBox.count - 1)
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
        dataSource.apply(snapshot, animatingDifferences: false)
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
            keyboardHeight = keyboardRect.height
            self.bottomConstraint.constant = keyboardHeight - 34
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardRect.height
            self.bottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
}

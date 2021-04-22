//
//  ChatViewController.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 21/04/2021.
//

import UIKit

class ChattingViewController: UIViewController {
    
    static let sectionHeaderElementKind = "section-header-element-kind"
    static let sectionFooterElementKind = "section-footer-element-kind"

    var dataSource: UICollectionViewDiffableDataSource<Int, Int>! = nil
//    var chatView: UICollectionView! = nil
    @IBOutlet weak var chatView: UICollectionView!
    
    var headersIndex = [IndexPath]()
    var touchPosition: CGPoint = CGPoint(x: 0, y: 0)
    private lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureOnTable(_:)))
        gesture.delegate = self
        gesture.cancelsTouchesInView = true
        return gesture
    }()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpNavigationBar()
        configureHierarchy()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    @objc func panGestureOnTable(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: chatView)
        if sender.state == .ended {
            chatView.visibleCells.forEach {
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
                if let cell = $0 as? MessContentCell {
                    cell.constraint.constant = (touchPosition.x - touchPoint.x) < 50 ? ((touchPosition.x - touchPoint.x) > 0 ? (touchPosition.x - touchPoint.x) : 0) : 50
                }
            }
            chatView.visibleSupplementaryViews(ofKind: ChattingViewController.sectionHeaderElementKind).forEach {
                if let cell = $0 as? HeaderSessionChat {
                    cell.constraint.constant = (touchPosition.x - touchPoint.x) < 50 ? ((touchPosition.x - touchPoint.x) > 0 ? (touchPosition.x - touchPoint.x) : 0) : 50
                }
            }
        }
    }
}

extension ChattingViewController {
    /// - Tag: PinnedHeader
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(44))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)

        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(55)),
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

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension ChattingViewController {
    func configureHierarchy() {
//        chatView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        chatView.frame = view.bounds
        chatView.collectionViewLayout = createLayout()
        chatView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        chatView.backgroundColor = .systemGray6
        view.addSubview(chatView)
        chatView.delegate = self
        chatView.register(UINib(nibName: MessContentCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: MessContentCell.reuseIdentifier)
        chatView.register(UINib(nibName: HeaderSessionChat.reuseIdentifier, bundle: nil), forSupplementaryViewOfKind: ChattingViewController.sectionHeaderElementKind, withReuseIdentifier: HeaderSessionChat.reuseIdentifier)
        
        chatView.addGestureRecognizer(panGesture)
    }
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
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MessContentCell.reuseIdentifier,
                for: indexPath) as? MessContentCell else { fatalError("Cannot create new cell") }
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
        let itemsPerSection = 5
        let sections = Array(0..<5)
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

extension ChattingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

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
}

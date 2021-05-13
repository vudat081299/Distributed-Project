//
//  MessagingViewController.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 10/04/2021.
//

import UIKit

class MessagingViewController: UIViewController {
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    private var collectionView: UICollectionView! = nil
    
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
        configureHierarchy()
        configureDataSource()
    
        navigationItem.searchController = searchController
        
        
        
//        var url = URLComponents(string: "http://\(ip)/api/users/getMessagesOfRoom/")!
//
//        url.queryItems = [
//            URLQueryItem(name: "sum", value: "\(currentUserID! > to ? "\(String(describing: currentUserID!))\(to)" : "\(to)\(String(describing: currentUserID!))")")
//        ]
//
//        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "?", with: "%3F")
//        print(url.string!)
        
    }
    
    func fetchBoxesData() {
        let getAll = ResourceRequest<User>(resourcePath: "users/nosql")
        getAll.get() { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    // async code here
                }
            case .failure:
                ErrorPresenter.showError(message: "There was an error getting the textModels", on: self)
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

}

struct ResolvedBoxesData: Decodable {
    
}







extension MessagingViewController {
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension MessagingViewController {
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.register(UINib(nibName: CustomListCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: CustomListCell.reuseIdentifier)
    }
    
    /// - Tag: CellRegistration
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<CustomListCell, Item> { (cell, indexPath, item) in
            cell.updateWithItem(item)
            cell.accessories = [.disclosureIndicator()]
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
//            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CustomListCell.reuseIdentifier,
                for: indexPath) as? CustomListCell else { fatalError("Cannot create new cell") }
            cell.updateWithItem(item)
            cell.accessories = []
            return cell
        }
        
        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        
        let resolvedBox = Auth.userBoxData
        var item: [Item] = []
        resolvedBox.forEach { box in
            var title = "Group"
            if box.type == .privateChat {
                for member in box.members {
                    if member != box.boxSpecification.creator {
                        title = member.uuidString
                        break
                    }
                }
            }
            item.append(Item(category: .weather, imageName: "avatar_9", title: title, description: box.boxSpecification.lastestMess ?? "Say hello to your friend!"))
        }
        //        snapshot.appendItems(Item.all)
        snapshot.appendItems(item)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension MessagingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let chattingViewController = ChattingViewController()
        chattingViewController.navigationItem.largeTitleDisplayMode = .never
        chattingViewController.tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(chattingViewController, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
}

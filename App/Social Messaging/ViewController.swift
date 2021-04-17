//
//  ViewController.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 10/04/2021.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Collection view setting up.
    static let headerElementKind = "header-element-kind"
    
    enum SectionType: Int, CaseIterable {
        case list, collection
    }
    
    class CellItem: Hashable {
        let image: UIImage?
        let data: (String?, String?) // (label, detaiLabel)
        let select: (() -> Void)? // select cell
        let cellClass: UITableViewCell // class of cell
        let viewControllerType: UIViewController.Type? // view show when select cell
        
        init(image: UIImage? = nil,
             data: (String?, String?) = (nil, nil),
             select: (() -> ())? = nil,
             cellClass: UITableViewCell = UITableViewCell(),
             viewControllerType: UIViewController.Type? = nil
        ) {
            self.image = image
            self.data = data
            self.select = select
            self.cellClass = cellClass
            self.viewControllerType = viewControllerType
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        static func == (lhs: CellItem, rhs: CellItem) -> Bool {
            return lhs.identifier == rhs.identifier
        }
        private let identifier = UUID()
    }
    
    class SectionItem {
        let cell: [CellItem]
        let sectionType: SectionType?
        let behavior: SectionKind?
        let supplementaryData: (String?, String?)
        let header: UICollectionReusableView?
        let footer: UICollectionReusableView?
        
        init(cell: [CellItem],
             sectionType: SectionType? = .list,
             behavior: SectionKind? = .continuous,
             supplementaryData: (String?, String?) = (nil, nil),
             header: UICollectionReusableView? = nil,
             footer: UICollectionReusableView? = nil
        ) {
            self.cell = cell
            self.sectionType = sectionType
            self.behavior = behavior
            self.supplementaryData = supplementaryData
            self.header = header
            self.footer = footer
        }
    }
    
    private lazy var listItems: [SectionItem] = {
        let listCell: [CellItem] = {
            var list: [CellItem] = []
            for i in 0...10 {
                let customCell = CellItem(data: ("\(i)", "\(i + 1)"), select: triggerCellAction)
                list.append(customCell)
            }
            return list
        }()
        let customCell = CellItem(data: ("1", "2"), select: triggerCellAction)
        return [
            SectionItem(cell: listCell, sectionType: .collection, behavior: .paging),
            SectionItem(cell: listCell, sectionType: .collection, behavior: .groupPaging),
            SectionItem(cell: listCell, sectionType: .collection, behavior: .continuousGroupLeadingBoundary),
            SectionItem(cell: listCell, sectionType: .list, behavior: .noneType),
            SectionItem(cell: listCell, sectionType: .collection, behavior: .groupPagingCentered),
            SectionItem(cell: listCell, sectionType: .list, behavior: .noneType),
            SectionItem(cell: listCell, sectionType: .collection, behavior: .continuous),
            SectionItem(cell: listCell, sectionType: .collection, behavior: .paging),
            SectionItem(cell: [CellItem(data: ("1", "2"), select: triggerCellAction, viewControllerType: UITableViewController.self)], sectionType: .collection, behavior: .groupPaging),
        ]
    }()
    
    func triggerCellAction() {
        print("Trigger cell action!")
    }

    /// - Tag: OrthogonalBehavior
    enum SectionKind: Int, CaseIterable {
        case continuous, continuousGroupLeadingBoundary, paging, groupPaging, groupPagingCentered, noneType
        func orthogonalScrollingBehavior() -> UICollectionLayoutSectionOrthogonalScrollingBehavior {
            switch self {
            case .noneType:
                return UICollectionLayoutSectionOrthogonalScrollingBehavior.none
            case .continuous:
                return UICollectionLayoutSectionOrthogonalScrollingBehavior.continuous
            case .continuousGroupLeadingBoundary:
                return UICollectionLayoutSectionOrthogonalScrollingBehavior.continuousGroupLeadingBoundary
            case .paging:
                return UICollectionLayoutSectionOrthogonalScrollingBehavior.paging
            case .groupPaging:
                return UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPaging
            case .groupPagingCentered:
                return UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPagingCentered
            }
        }
    }
    var dataSource: UICollectionViewDiffableDataSource<Int, Int>! = nil
    var collectionView: UICollectionView! = nil
    
    
    
    // MARK: - Navbar components.
    let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "New Search"
        searchController.searchBar.searchBarStyle = .minimal
//        searchController.dimsBackgroundDuringPresentation = false // was deprecated in iOS 12.0
        searchController.definesPresentationContext = true
       return searchController
    }()
    let leftBarItem: UIBarButtonItem = {
        let bt = UIBarButtonItem(title: "Action", style: .done, target: nil, action: Selector(("leftBarButtonItemAction")))
        return bt
    }()
    let rightBarItem: UIBarButtonItem = {
        let bt = UIBarButtonItem(image: UIImage(systemName: "bookmark.circle"), style: .plain, target: nil, action: Selector(("rightBarItemAction")))
        return bt
    }()
    
    @objc func leftBarItemAction() {
        print("Left bar button was pressed!")
    }
    @objc func rightBarItemAction() {
        print("Right bar button was pressed!")
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.sizeToFit()
        
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.searchController = searchController
//        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.leftBarButtonItem = leftBarItem
        navigationItem.rightBarButtonItem = rightBarItem
        
        view.backgroundColor = .lightGray
        definesPresentationContext = true
        
        // Setting up collection view.
        configureHierarchy()
        configureDataSource()
        
//        self.searchController.hidesNavigationBarDuringPresentation = true
//        self.searchController.searchBar.searchBarStyle = .prominent
//        // Include the search bar within the navigation bar.
//        self.navigationItem.titleView = self.searchController.searchBar
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "pushSeque" {
//            // This segue is pushing a detailed view controller.
//            if let indexPath = self.tableView.indexPathForSelectedRow {
//                segue.destination.title = dataSource.city(index: indexPath.row)
//            }
//
//            // You choose not to have a large title for the destination view controller.
//            segue.destination.navigationItem.largeTitleDisplayMode = .never
//        } else {
//            // This segue is popping you back up the navigation stack.
//        }
//    }

}

// MARK: - Collection View.
extension ViewController {
    
    //   +-----------------------------------------------------+
    //   | +---------------------------------+  +-----------+  |
    //   | |                                 |  |           |  |
    //   | |                                 |  |           |  |
    //   | |                                 |  |     1     |  |
    //   | |                                 |  |           |  |
    //   | |                                 |  |           |  |
    //   | |                                 |  +-----------+  |
    //   | |               0                 |                 |
    //   | |                                 |  +-----------+  |
    //   | |                                 |  |           |  |
    //   | |                                 |  |           |  |
    //   | |                                 |  |     2     |  |
    //   | |                                 |  |           |  |
    //   | |                                 |  |           |  |
    //   | +---------------------------------+  +-----------+  |
    //   +-----------------------------------------------------+
    
    func createLayout() -> UICollectionViewLayout {
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { [self]
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
//            guard let sectionKind = SectionKind(rawValue: sectionIndex) else { fatalError("unknown section kind") }
            guard let sectionKind = listItems[sectionIndex].behavior, let sectionType = listItems[sectionIndex].sectionType else { fatalError("unknown section kind") }
            switch sectionType {
            case .collection:
                let leadingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                                                            widthDimension: .fractionalWidth(0.7), heightDimension: .fractionalHeight(1.0)))
                leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                
                let trailingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                                                            widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.3)))
                trailingItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(
                                                                        widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(1.0)),
                                                                     subitem: trailingItem,
                                                                     count: 2)
                
                let orthogonallyScrolls = sectionKind.orthogonalScrollingBehavior() != .none
                let containerGroupFractionalWidth = orthogonallyScrolls ? CGFloat(0.85) : CGFloat(1.0)
                let containerGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(containerGroupFractionalWidth),
                                                       heightDimension: .fractionalHeight(0.4)),
                    subitems: [leadingItem, trailingGroup])
                let section = NSCollectionLayoutSection(group: containerGroup)
                section.orthogonalScrollingBehavior = sectionKind.orthogonalScrollingBehavior()
                
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(44)),
                    elementKind: ViewController.headerElementKind,
                    alignment: .top)
                section.boundarySupplementaryItems = [sectionHeader]
                return section
            case .list:
                let section: NSCollectionLayoutSection
                var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
//                configuration.leadingSwipeActionsConfigurationProvider = { [weak self] (indexPath) in
//                    guard let self = self else { return nil }
//                    guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
//                    return self.leadingSwipeActionConfigurationForListCellItem(item)
//                }
                section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
                
                return section
            }
            
        }, configuration: config)
        return layout
    }
    
    // MARK: - List cell
    /// - Tag: ConfigureListCell
    func configuredListCell() -> UICollectionView.CellRegistration<CustomCollectionViewListCell, Int> {
        return UICollectionView.CellRegistration<CustomCollectionViewListCell, Int> { [weak self] (cell, indexPath, item) in
//            var content = UIListContentConfiguration.valueCell()
//            content.text = "List cell!"
//            content.secondaryText = "detail"
//            cell.contentConfiguration = content
            cell.icon.image = UIImage(named: "avatar")
            cell.textLabel.text = "Name"
        }
    }
}



// MARK: - CV DataSource.
extension ViewController {
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemGroupedBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "CustomCollectionViewListCell", bundle: nil), forCellWithReuseIdentifier: CustomCollectionViewListCell.reuseIdentifier)
    }
    func configureDataSource() {
        
        // Cell for Row.
        let cellRegistration = UICollectionView.CellRegistration<TextCell, Int> { [self] (cell, indexPath, identifier) in
//            // Populate the cell with our item description.
//            cell.label.text = "\(indexPath.section), \(indexPath.item)"
//            cell.contentView.backgroundColor = .cornflowerBlue
//            cell.contentView.layer.borderColor = UIColor.black.cgColor
//            cell.contentView.layer.borderWidth = 1
//            cell.contentView.layer.cornerRadius = 8
//            cell.label.textAlignment = .center
//            cell.label.font = UIFont.preferredFont(forTextStyle: .title1)
            
            cell.label.text = listItems[indexPath.section].cell[indexPath.row].data.0
            cell.contentView.backgroundColor = .cornflowerBlue
            cell.contentView.layer.borderColor = .blueLight06
            cell.contentView.layer.borderWidth = 4
            cell.contentView.layer.cornerRadius = 8
            cell.label.textColor = .white
            cell.label.textAlignment = .center
            cell.label.font = UIFont.preferredFont(forTextStyle: .title1)
        }
        
//        let customCellRegistration = UICollectionView.CellRegistration<CustomCollectionViewListCell, Int> { [self] (cell, indexPath, item) in
//            cell.icon.image = UIImage(named: "avatar")
//            cell.textLabel.text = "Name"
//        }
        
        let customCellRegistration = UICollectionView.CellRegistration<CustomCollectionViewListCell, Int> { [self] (cell, indexPath, item) in
            if cell.icon != nil && cell.textLabel != nil {
                cell.icon.image = UIImage(named: "avatar")
                cell.textLabel.text = "Name"
            } else {
                
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, Int>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
            // Return the cell.
            switch self.listItems[indexPath.section].sectionType {
            case .list:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CustomCollectionViewListCell.reuseIdentifier,
                    for: indexPath) as? CustomCollectionViewListCell else { fatalError("Cannot create new cell") }
                return cell
//                return collectionView.dequeueConfiguredReusableCell(using: customCellRegistration, for: indexPath, item: identifier)
            case .collection:
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
            default:
                return nil
            }
        }
        
        // Header for Section.
        let supplementaryRegistration = UICollectionView.SupplementaryRegistration
        <TitleSupplementaryView>(elementKind: ViewController.headerElementKind) { [self]
            (supplementaryView, string, indexPath) in
//            let sectionKind = SectionKind(rawValue: indexPath.section)!
//            supplementaryView.label.text = "." + String(describing: sectionKind)
            supplementaryView.label.text = "." + String(describing: listItems[indexPath.section].behavior!)
        }
        let customSupplementaryRegistration = UICollectionView.SupplementaryRegistration
        <CustomSupplementaryView>(elementKind: ViewController.headerElementKind) { [self]
            (supplementaryView, string, indexPath) in
            supplementaryView.backgroundColor = .black
        }
        dataSource.supplementaryViewProvider = { (view, kind, index) in
//            if index[0] % 2 == 0 {
//                return self.collectionView.dequeueConfiguredReusableSupplementary(
//                    using: customSupplementaryRegistration, for: index)
//            }
            return self.collectionView.dequeueConfiguredReusableSupplementary(
                using: supplementaryRegistration, for: index)
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        var identifierOffset = 0
//        SectionKind.allCases.forEach {
//            snapshot.appendSections([$0.rawValue])
//            let maxIdentifier = identifierOffset + itemsPerSection
//            snapshot.appendItems(Array(identifierOffset..<maxIdentifier))
//            identifierOffset += itemsPerSection
//        }
        listItems.forEach {
            let itemsPerSection = $0.cell.count
            snapshot.appendSections([snapshot.numberOfSections])
            snapshot.appendItems(Array(identifierOffset..<(identifierOffset + itemsPerSection)))
            identifierOffset += $0.cell.count
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}



// MARK: - CV Delegate.
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
//        guard let menuItem = self.dataSource.itemIdentifier(for: indexPath) else { return }
        
        let cellItem = listItems[indexPath.section].cell[indexPath.row]
        if let action = cellItem.select { action() }
        if let viewController = cellItem.viewControllerType {
            navigationController?.pushViewController(viewController.init(), animated: true)
        }
        
//        if let viewController = selectedCellData.showViewControllers {
//            let vc = viewController.init()
//            vc.view.backgroundColor = .white
//            vc.navigationItem.largeTitleDisplayMode = .never
//            navigationController?.pushViewController(vc, animated: true)
//
//        }
    }
    
}

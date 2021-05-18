//
//  SignUpViewController.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 18/05/2021.
//

import UIKit

class SignUpViewController: UIViewController {
    
    // MARK: - IBOutlet.
    @IBOutlet weak var tableView: UITableView!

    
    
    // MARK: - Data structure.
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
        let supplementaryData: (String?, String?)
        let header: UICollectionReusableView?
        let footer: UICollectionReusableView?
        
        init(cell: [CellItem],
             sectionType: SectionType? = .list,
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
    
    
    // MARK: - TableView Data.
    let data = [[""]]

    
    
    // MARK: - Life cycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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

// MARK: - TableView.
extension SignUpViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
}





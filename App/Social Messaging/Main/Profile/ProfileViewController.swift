//
//  ProfileViewController.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 10/04/2021.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.register(UINib(nibName: "Cell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.register(UINib(nibName: "HeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "HeaderTableViewCell")
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBOutlet weak var tableView: UITableView!

    var headersIndex = [IndexPath]()
}

extension ProfileViewController: UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderTableViewCell") as! HeaderTableViewCell
            cell.centerLabel.text = "sanjay"
            cell.centerLabel.center.x = view.center.x
            if !headersIndex.contains(indexPath) {
                headersIndex.append(indexPath)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
            cell.leftLabel.text = "Message \(indexPath.row)"
            cell.rightLabel.text = indexPath.row.description
            return cell
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for i in headersIndex {
            if let cell = tableView.cellForRow(at: i) {
                if tableView.visibleCells.contains(cell) {
                    let header = cell as! HeaderTableViewCell
                    header.centerLabel.center.x = view.center.x + scrollView.contentOffset.x
                }
            }
            
        }
        
    }
}

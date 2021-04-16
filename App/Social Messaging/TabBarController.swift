//
//  TabBarController.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 10/04/2021.
//

import UIKit

class TabBarController: UITabBarController {
    
    let listTab = ["Home", "Notifications", "Chat", "Profile"]
    
    var viewController: ViewController = {
        let vc = ViewController()
        return vc
    }()
    var profileViewController: ProfileViewController = {
        let vc = ProfileViewController()
        return vc
    }()
    var messagingViewController: MessagingViewController = {
        let vc = MessagingViewController()
        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewController.tabBarItem.image = UIImage(systemName: "house")
        viewController.tabBarItem.selectedImage = UIImage(named: "house.fill")
        messagingViewController.tabBarItem.image = UIImage(systemName: "message")
        messagingViewController.tabBarItem.selectedImage = UIImage(named: "message.fill")
        profileViewController.tabBarItem.image = UIImage(systemName: "person")
        profileViewController.tabBarItem.selectedImage = UIImage(named: "person.fill")
        
        viewControllers?.append(contentsOf: [{
            let vc = UIViewController()
            vc.view.backgroundColor = .white
            vc.tabBarItem.image = UIImage(systemName: "graduationcap")
            vc.tabBarItem.selectedImage = UIImage(named: "graduationcap.fill")
            return vc
        }(), messagingViewController, profileViewController])
        //        viewControllers = [viewController, messagingViewController, profileViewController]
        for (index, tabBarItem) in tabBar.items!.enumerated() {
            tabBarItem.title = listTab[index]
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

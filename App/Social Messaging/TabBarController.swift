//
//  TabBarController.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 10/04/2021.
//

import UIKit

// App global variables.






struct ViewControllerData {
    let title: String
    let iconNormal: String
    let selectedIcon: String
    let viewController: UINavigationController
    
    static var viewControllerDatas: [ViewControllerData] = {
        let array = [
            ViewControllerData(title: "Notifications", iconNormal: "graduationcap", selectedIcon: "graduationcap.fill", viewController: UINavigationController(rootViewController: UITableViewController())),
            ViewControllerData(title: "Message", iconNormal: "message", selectedIcon: "message.fill", viewController: UINavigationController(rootViewController: MessagingViewController())),
            ViewControllerData(title: "Profile", iconNormal: "person", selectedIcon: "person.fill", viewController: UINavigationController(rootViewController: ProfileViewController())),
            ViewControllerData(title: "NewMessage", iconNormal: "person", selectedIcon: "person.fill", viewController: UINavigationController(rootViewController: MessagingViewControllerTableView()))
        ]
        var dataList: [ViewControllerData] = []
        array.forEach {
            $0.viewController.topViewController?.title = $0.title
            $0.viewController.tabBarItem.image = UIImage(systemName: $0.iconNormal)
            $0.viewController.tabBarItem.selectedImage = UIImage(systemName: $0.selectedIcon)
            $0.viewController.navigationBar.prefersLargeTitles = true
            $0.viewController.navigationBar.sizeToFit()
            $0.viewController.navigationItem.largeTitleDisplayMode = .always
            dataList.append($0)
        }
        return dataList
    }()
}

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ViewControllerData.viewControllerDatas.forEach {
            viewControllers?.append($0.viewController)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startListenWebSocket()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func startListenWebSocket() {
        let ws = WebSocket("ws://\(ip)/connecttowsserver/\(Auth.userId ?? "")")
        print(ws.url)
        ws.event.close = { [weak self] code, reason, clean in print("WebSocket did close!") }
        
        ws.event.message = { message in
            let jsonData = (message as! String).data(using: .utf8)!
            
            do {
                /*
                 {
                    "type": 1,
                    "majorData": {"boxId": "609d48c4a15ec87fb58b382d", "creationDate": 1620184184.11111111111111, "text": "tess", "fileId": "6094d82ddba87b2eb8b413f3", "type": 1, "senderId": "609d482b1498c4bbdcc46c55", "senderIdOnRDBMS": "4E605ACB-55CD-4E9F-9DAD-948CA2E901BC"}
                 }
                 */
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let resolvedData = try decoder.decode(WSResolvedMessage.self, from: jsonData)
                print("Resolved WS Data successful!")
                switch resolvedData.type {
                case .notify:
                    break
                    
                case .newMess:
                    print(resolvedData)
                    break
                    
                case .newBox: // new box
                    break
                    
                case .userTyping: // typing
                    break
                }
                
            } catch {
                print(error.localizedDescription)
            }
            
            
        }
    }

}

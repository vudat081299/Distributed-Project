//
//  Auth.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 24/12/2020.
//

import UIKit

enum AuthResult {
    case success
    case failure
}

var currentUserID: String {
    get {
        return UserDefaults.standard.string(forKey: "UserID")!
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "UserID")
    }
}
class Auth {
    static let defaultsKey = "AUTH-TOKEN"
    let defaults = UserDefaults.standard
    
    var token: String? {
        get {
            return defaults.string(forKey: Auth.defaultsKey)
        }
        set {
            defaults.set(newValue, forKey: Auth.defaultsKey)
        }
    }
    
    func logout(on viewController: UIViewController?) {
        self.token = nil
        DispatchQueue.main.async {
//      guard let applicationDelegate = UIApplication.shared.delegate as? SceneDelegate else {
//        return
//      }
//      let rootController = UIStoryboard(name: "Login", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginNavigation")
//      applicationDelegate.window?.rootViewController = rootController
        
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()!
        vc.modalPresentationStyle = .fullScreen
        viewController!.present(vc, animated:true, completion:nil)
    }
  }
    
    func login(username: String, password: String, completion: @escaping (AuthResult) -> Void) {
        let path = "http://\(ip)/api/users/login"
        guard let url = URL(string: path) else {
            fatalError()
        }
        guard let loginString = "\(username):\(password)".data(using: .utf8)?.base64EncodedString() else {
            fatalError()
        }
        
        var loginRequest = URLRequest(url: url)
        loginRequest.addValue("Basic \(loginString)", forHTTPHeaderField: "Authorization")
        loginRequest.httpMethod = "POST"
        
        let dataTask = URLSession.shared.dataTask(with: loginRequest) { data, response, _ in
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let jsonData = data else {
                completion(.failure)
                return
            }
            
            do {
                let token = try JSONDecoder()
                    .decode(Token.self, from: jsonData)
                self.token = token.value
                currentUserID = token.user.id.uuidString
                completion(.success)
            } catch {
                completion(.failure)
            }
        }
        dataTask.resume()
    }
}

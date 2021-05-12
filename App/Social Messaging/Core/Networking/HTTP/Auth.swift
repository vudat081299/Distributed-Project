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

class Auth {
    static let defaultsKey = "AUTH-TOKEN"
    static let userIdKey = "userIdKey"
    static let _idKey = "_idKey"
    static let userRSMNoSQLPublic = "userRSMNoSQLPublic"
    let defaults = UserDefaults.standard
    
    var token: String? {
        get {
            return defaults.string(forKey: Auth.defaultsKey)
        }
        set {
            defaults.set(newValue, forKey: Auth.defaultsKey)
        }
    }
    
    var _id: String? {
        get {
            return defaults.string(forKey: Auth._idKey)
        }
        set {
            defaults.set(newValue, forKey: Auth._idKey)
        }
    }
    
    var userId: String? {
        get {
            return defaults.string(forKey: Auth.userIdKey)
        }
        set {
            defaults.set(newValue, forKey: Auth.userIdKey)
        }
    }
    
    var currentUserID: String {
        get {
            return defaults.string(forKey: "UserID")!
        }
        set {
            defaults.set(newValue, forKey: "UserID")
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
                self.userId = token.user.id.uuidString
                self.currentUserID = token.user.id.uuidString
                completion(.success)
            } catch {
                completion(.failure)
            }
        }
        dataTask.resume()
    }
    
    func preparePrivateData(completion: @escaping (AuthResult) -> Void) {
        let path = "http://\(ip)/api/users/getuserprofileidnosql/\(userId!)"
        guard let url = URL(string: path) else {
            fatalError()
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")

        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let jsonData = data else {
                completion(.failure)
                return
            }

            do {
                let decoder = JSONDecoder()
                self._id = String(decoding: jsonData, as: UTF8.self)
                completion(.success)
            } catch {
                completion(.failure)
            }
        }
        dataTask.resume()
    }
}

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
    static let userDefaults = UserDefaults.standard
    static var avatar: UIImage!
    
    static var token: String? {
        get {
            return userDefaults.string(forKey: Auth.defaultsKey)
        }
        set {
            userDefaults.set(newValue, forKey: Auth.defaultsKey)
        }
    }
    
    static var _id: String? {
        get {
            return userDefaults.string(forKey: Auth._idKey)
        }
        set {
            userDefaults.set(newValue, forKey: Auth._idKey)
        }
    }
    
    static var userId: String? {
        get {
            return userDefaults.string(forKey: Auth.userIdKey)
        }
        set {
            userDefaults.set(newValue, forKey: Auth.userIdKey)
        }
    }
    
    static var currentUserID: String? {
        get {
            return userDefaults.string(forKey: "UserID")!
        }
        set {
            userDefaults.set(newValue, forKey: "UserID")
        }
    }
    
    static var userProfileData: User? {
        get {
            if let savedData = userDefaults.object(forKey: user_profile_data_Key) as? Data {
                if let loadedUserProfileData = try? JSONDecoder().decode(User.self, from: savedData) {
                    return loadedUserProfileData
                }
            }
            return nil
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                userDefaults.set(encoded, forKey: user_profile_data_Key)
            }
        }
    }
    
    static var userBoxData: [ResolvedBox] {
        get {
            if let savedData = userDefaults.object(forKey: user_box_data_Key) as? Data {
                if let loadedUserBoxData = try? JSONDecoder().decode([ResolvedBox].self, from: savedData) {
                    return loadedUserBoxData
                }
            }
            return []
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                userDefaults.set(encoded, forKey: user_box_data_Key)
            }
        }
    }
    
    static func logout(on viewController: UIViewController?) {
        self.token = nil
        self.userProfileData = nil
        self._id = nil
        self.userId = nil
        self.userBoxData = []
        self.currentUserID = nil
        
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
    
    static func login(username: String, password: String, completion: @escaping (AuthResult) -> Void) {
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
                Auth.token = token.value
                Auth.userId = token.user.id.uuidString
                Auth.currentUserID = token.user.id.uuidString
                Auth.prepareUserProfileData()
                
                completion(.success)
            } catch {
                completion(.failure)
            }
        }
        dataTask.resume()
    }
    
    static func prepareUserProfileData() {
        // method 1
        let request_user = ResourceRequest<User>(resourcePath: "users/getauthuserdata")
        request_user.get(token: Auth.token) { result in
            switch result {
            case .success(let data):
                Auth.userProfileData = data
                do {
                    avatar = UIImage(data: try Data(contentsOf: URL(string: "http://192.168.1.65:8080/api/users/getfiletest/60a09d19901feaeae8684069")!))
                    
                } catch {
                    print(error.localizedDescription)
                }
            case .failure:
                break
            }
        }
        
//        let request_box = ResourceRequest<ResolvedBox>(resourcePath: "mess")
//        request_box.getArray(token: Auth.token) { result in
//            switch result {
//            case .success(let data):
//                Auth.userBoxData = data
//            case .failure:
//                break
//            }
//        }
        
        // method 2
//        let path = "http://\(ip)/api/users/getauthuserdata"
//        guard let url = URL(string: path) else {
////            fatalError()
//            completion(.failure)
//            return
//        }
//        var urlRequest = URLRequest(url: url)
//        urlRequest.addValue("Bearer \(Auth.token!)", forHTTPHeaderField: "Authorization")
//
//        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
//            guard let httpResponse = response as? HTTPURLResponse,
//                  httpResponse.statusCode == 200,
//                  let jsonData = data
//            else {
//                completion(.failure)
//                return
//            }
//
//            do {
//                let userProfileData: User = try JSONDecoder().decode(User.self, from: jsonData)
////                userDefaults.set(jsonData, forKey: user_profile_data_Key)
//                Auth.userProfileData = userProfileData
//
//                completion(.success)
//            } catch {
//                completion(.failure)
//            }
//        }
//        dataTask.resume()
    }
}

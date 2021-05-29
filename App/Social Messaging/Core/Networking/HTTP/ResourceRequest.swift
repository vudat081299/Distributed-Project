//
//  ResourceRequest.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 11/12/2020.
//

import Foundation

// MARK: - Specifications.
var domain: String? {
    get {
        return UserDefaults.standard.string(forKey: domain_key) ?? "192.168.1.65:8080"
    }
    set {
        UserDefaults.standard.set(newValue, forKey: domain_key)
        let endIndexOfIp = newValue?.firstIndex(of: Character(":"))
        if let index = endIndexOfIp, newValue != nil && newValue!.count >= 9 {
            let ipSubString = newValue![newValue!.startIndex..<index]
            let startIndexOfPort = newValue?.index(index, offsetBy: 1)
            let portSubString = newValue![startIndexOfPort!..<newValue!.endIndex]
            onlyIp = String(ipSubString)
            port = String(portSubString)
            chatPort = "8081"
            print("Network specification ip:\(onlyIp!) \nport:\(port!) \ndomain:\(domain!)")
        }
    }
}

var onlyIp: String? {
    get {
        return UserDefaults.standard.string(forKey: ip_key) ?? "192.168.1.65"
    }
    set {
        UserDefaults.standard.set(newValue, forKey: ip_key)
    }
}

var port: String? {
    get {
        return UserDefaults.standard.string(forKey: port_key) ?? "8080"
    }
    set {
        UserDefaults.standard.set(newValue, forKey: port_key)
    }
}

var chatPort: String? {
    get {
        return UserDefaults.standard.string(forKey: chatting_port_key) ?? "8081"
    }
    set {
        UserDefaults.standard.set(newValue, forKey: chatting_port_key)
    }
}

var basedURL: String {
    return "http://\(domain!)/api/"
}




// MARK: - enum.
enum GetResourcesRequest<ResourceType> {
  case success([ResourceType])
  case failure
}
enum GetAllUsersRequest<ResourceType> {
  case success(ResourceType)
  case failure
}
enum GetAllMessagesRequest<ResponseType> {
  case success(ResponseType)
  case failure
}

enum GetAnnotationRequest {
  case success(Data)
  case failure
}

enum SaveResult<ResourceType> {
  case success(ResourceType)
  case failure
}

enum SaveResultsCreateUser<ResponseType> {
  case success(ResponseType)
  case failure
}



// Remake ResourcesRequest
enum ResourcesRequest<ResolveType> {
    case success(ResolveType)
    case failure
}

enum ResourcesRequestGetArray<ResolveType> {
    case success([ResolveType])
    case failure
}

enum PutRequest {
    case success
    case failure
}


struct ResourceRequest<PostType, ResolveType> where PostType: Codable, ResolveType: Codable {
    
    let resourceURL: URL
    
    init(resourcePath: String) {
        guard let resourceURL = URL(string: basedURL) else {
            fatalError()
        }
        self.resourceURL = resourceURL.appendingPathComponent(resourcePath)
    }
    
    
    
    // MARK: - Get.
    func get(token: Bool = false,
             completion: @escaping (ResourcesRequest<PostType>) -> Void) {
        print(resourceURL)
        var urlRequest = URLRequest(url: resourceURL)
        if token {
            urlRequest.addValue("Bearer \(Auth.token!)", forHTTPHeaderField: "Authorization")
//            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let jsonData = data
            else {
                completion(.failure)
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                let resources: PostType = try decoder.decode(PostType.self, from: jsonData)
                completion(.success(resources))
            } catch {
                completion(.failure)
            }
        }
        dataTask.resume()
    }
    
    func getArray(token: Bool = false,
                  completion: @escaping (ResourcesRequestGetArray<PostType>) -> Void) {
        print(resourceURL)
        var urlRequest = URLRequest(url: resourceURL)
        if token {
            urlRequest.addValue("Bearer \(Auth.token!)", forHTTPHeaderField: "Authorization")
//            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let jsonData = data
            else {
                completion(.failure)
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                let resources: [PostType] = try decoder.decode([PostType].self, from: jsonData)
                completion(.success(resources))
            } catch {
                completion(.failure)
            }
        }
        dataTask.resume()
    }
    
    
    
    
    func getFile(token: Bool = false,
                 completion: @escaping (ResourcesRequest<PostType>) -> Void) {
        print(resourceURL)
        var urlRequest = URLRequest(url: resourceURL)
        if token {
            urlRequest.addValue("Bearer \(Auth.token!)", forHTTPHeaderField: "Authorization")
//            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let jsonData = data
            else {
                completion(.failure)
                return
            }
            do {
                let decoder = JSONDecoder()
                let resources: PostType = try decoder.decode(PostType.self, from: jsonData)
                completion(.success(resources))
            } catch {
                completion(.failure)
            }
        }
        dataTask.resume()
    }
    
    
    
    // MARK: - Post.
    func post(token: Bool = false,
              _ resource: PostType,
              completion: @escaping (ResourcesRequest<PostType>) -> Void) {
        print(resourceURL)
        do {
            var urlRequest = URLRequest(url: resourceURL)
            if token {
                urlRequest.addValue("Bearer \(Auth.token!)", forHTTPHeaderField: "Authorization")
            }
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(resource)
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200,
                      let jsonData = data
                else {
                    completion(.failure)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let resource = try decoder.decode(PostType.self, from: jsonData)
                    completion(.success(resource))
                } catch {
                    completion(.failure)
                }
            }
            dataTask.resume()
        } catch {
            completion(.failure)
        }
    }
    func postFile(token: Bool = false,
                  _ resource: PostType,
                  completion: @escaping (ResourcesRequest<PostType>) -> Void) {
        print(resourceURL)
        do {
            var urlRequest = URLRequest(url: resourceURL)
            if token {
                urlRequest.addValue("Bearer \(Auth.token!)", forHTTPHeaderField: "Authorization")
            }
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(resource)
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200,
                      let jsonData = data
                else {
                    completion(.failure)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let resource = try decoder.decode(PostType.self, from: jsonData)
                    completion(.success(resource))
                } catch {
                    completion(.failure)
                }
            }
            dataTask.resume()
        } catch {
            completion(.failure)
        }
    }
    
    
    
    // MARK: - Put.
    func put(token: Bool = false,
                  _ resource: PostType,
                  completion: @escaping (PutRequest) -> Void) {
        print(resourceURL)
        do {
            var urlRequest = URLRequest(url: resourceURL)
            if token {
                urlRequest.addValue("Bearer \(Auth.token!)", forHTTPHeaderField: "Authorization")
            }
            urlRequest.httpMethod = "PUT"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(resource)
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200,
                      let jsonData = data
                else {
                    completion(.failure)
                    return
                }
                do {
                    completion(.success)
                } catch {
                    completion(.failure)
                }
            }
            dataTask.resume()
        } catch {
            completion(.failure)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
    
    
//    func getAll(completion: @escaping (GetResourcesRequest<ResourceType>) -> Void) {
//      let dataTask = URLSession.shared.dataTask(with: resourceURL) { (data, response, error) in
//        guard let jsonData = data else {
//          completion(.failure)
//          return
//        }
//
//        do {
//          let decoder = JSONDecoder()
//          let resources: [ResourceType] = try decoder.decode([ResourceType].self, from: jsonData)
//          completion(.success(resources))
//        } catch {
//          completion(.failure)
//        }
//      }
//      dataTask.resume()
//    }
    
    func getAllMessages(url: URLComponents, completion: @escaping (GetAllMessagesRequest<ResponseType>) -> Void) {
        let urlReq = url.url!
      let dataTask = URLSession.shared.dataTask(with: urlReq) { (data, response, error) in
        guard let jsonData = data else {
          completion(.failure)
          return
        }

        do {
          let decoder = JSONDecoder()
          let resources = try decoder.decode(ResponseType.self, from: jsonData)
          completion(.success(resources))
        } catch {
          completion(.failure)
        }
      }
      dataTask.resume()
    }
    func getAllUsers(completion: @escaping (GetAllUsersRequest<ResourceType>) -> Void) {
      let dataTask = URLSession.shared.dataTask(with: resourceURL) { (data, response, error) in
        guard let jsonData = data else {
          completion(.failure)
          return
        }

        do {
          let decoder = JSONDecoder()
          let resources: ResourceType = try decoder.decode(ResourceType.self, from: jsonData)
          completion(.success(resources))
        } catch {
          completion(.failure)
        }
      }
      dataTask.resume()
    }
    func getAllAnnotations(completion: @escaping (GetAnnotationRequest) -> Void) {
      let dataTask = URLSession.shared.dataTask(with: resourceURL) { (data, response, error) in
        guard let jsonData = data else {
          completion(.failure)
          return
        }

        do {
//          let decoder = JSONDecoder()
//          let resources: [ResourceType] = try decoder.decode([ResourceType].self, from: jsonData)
          completion(.success(jsonData))
        } catch {
          completion(.failure)
        }
      }
      dataTask.resume()
    }
    
    func save(_ resourceToSave: ResourceType, completion: @escaping (SaveResult<ResourceType>) -> Void) {
      do {
        var urlRequest = URLRequest(url: resourceURL)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(resourceToSave)
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
          guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200,
            let jsonData = data else {
              print(1)
              completion(.failure)
              return
          }
          print(data)
          print(response)
          do {
            let decoder = JSONDecoder()
            let resource = try decoder.decode(ResourceType.self, from: jsonData)
            completion(.success(resource))
          } catch {
              print(2)
            completion(.failure)
          }
        }
        dataTask.resume()
      } catch {
          print(3)
        completion(.failure)
      }
    }
    
    func saveuser(_ resourceToSave: ResourceType, completion: @escaping (SaveResult<ResponseType>) -> Void) {
      do {
        var urlRequest = URLRequest(url: resourceURL)
        print(urlRequest)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(resourceToSave)
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
          guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200,
            let jsonData = data else {
              print(1)
              completion(.failure)
              return
          }
          print(data)
          print(response)
          do {
            let decoder = JSONDecoder()
            let responseParse = try decoder.decode(ResponseType.self, from: jsonData)
            completion(.success(responseParse))
          } catch {
              print(2)
            completion(.failure)
          }
        }
        dataTask.resume()
      } catch {
          print(3)
        completion(.failure)
      }
    }
 */
}

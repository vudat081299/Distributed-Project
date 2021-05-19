//
//  ResourceRequest.swift
//  Social Messaging
//
//  Created by Vũ Quý Đạt  on 11/12/2020.
//

import Foundation

var ip = "192.168.1.65:8080"

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
enum ResourcesRequest<ResourceType> {
    case success(ResourceType)
    case failure
}

enum ResourcesRequestGetArray<ResourceType> {
    case success([ResourceType])
    case failure
}

struct ResourceRequest<ResourceType> where ResourceType: Codable {
    
    let baseURL = "http://\(ip)/api/"
    let resourceURL: URL
    
    init(resourcePath: String) {
        guard let resourceURL = URL(string: baseURL) else {
            fatalError()
        }
        self.resourceURL = resourceURL.appendingPathComponent(resourcePath)
    }
    
    
    
    // MARK: - Get.
    func get(token: String? = nil,
             completion: @escaping (ResourcesRequest<ResourceType>) -> Void) {
        var urlRequest = URLRequest(url: resourceURL)
        if token != nil {
            urlRequest.addValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
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
                let resources: ResourceType = try decoder.decode(ResourceType.self, from: jsonData)
                completion(.success(resources))
            } catch {
                completion(.failure)
            }
        }
        dataTask.resume()
    }
    
    func getArray(token: String? = nil,
                  completion: @escaping (ResourcesRequestGetArray<ResourceType>) -> Void) {
        var urlRequest = URLRequest(url: resourceURL)
        print(resourceURL)
        if token != nil {
            urlRequest.addValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
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
                let resources: [ResourceType] = try decoder.decode([ResourceType].self, from: jsonData)
                completion(.success(resources))
            } catch {
                completion(.failure)
            }
        }
        dataTask.resume()
    }
    
    
    
    
    func getFile(token: String? = nil,
                 completion: @escaping (ResourcesRequest<ResourceType>) -> Void) {
        var urlRequest = URLRequest(url: resourceURL)
        if token != nil {
            urlRequest.addValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
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
                let resources: ResourceType = try decoder.decode(ResourceType.self, from: jsonData)
                completion(.success(resources))
            } catch {
                completion(.failure)
            }
        }
        dataTask.resume()
    }
    
    
    
    // MARK: - Post.
    func post(token: String? = nil,
              _ resource: ResourceType,
              completion: @escaping (ResourcesRequest<ResourceType>) -> Void) {
        do {
            var urlRequest = URLRequest(url: resourceURL)
            if token != nil {
                urlRequest.addValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
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
                    let resource = try decoder.decode(ResourceType.self, from: jsonData)
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

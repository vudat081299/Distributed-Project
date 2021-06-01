//
//  ResourceRequest.swift
//  MyMapKit
//
//  Created by Vũ Quý Đạt  on 11/12/2020.
//

import Foundation

enum GetResourcesRequest<ResourceType> {
  case success([ResourceType])
  case failure
}

enum SaveResult<ResourceType> {
  case success(ResourceType)
  case failure
}

struct ResourceRequest<ResourceType> where ResourceType: Codable {

  let baseURL = "http://192.168.1.65:8080/api/"
  let resourceURL: URL

  init(resourcePath: String) {
    guard let resourceURL = URL(string: baseURL) else {
      fatalError()
    }

    self.resourceURL = resourceURL.appendingPathComponent(resourcePath)
  }

  func getAll(completion: @escaping (GetResourcesRequest<ResourceType>) -> Void) {
    let dataTask = URLSession.shared.dataTask(with: resourceURL) { (data, response, error) in
      guard let jsonData = data else {
        completion(.failure)
        return
      }

      do {
        let decoder = JSONDecoder()
        let resources: [ResourceType] = try decoder.decode([ResourceType].self, from: jsonData)
        completion(.success(resources))
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
}

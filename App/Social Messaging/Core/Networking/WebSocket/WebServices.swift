/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
// MARK: - Reference: From Raywenderlich's vapor-swift project of Vapor swift server-side bundle.

import Foundation

struct TrackingSession: Codable {
  let code: Int
    let message: String
    let data: InFoWS
}
struct InFoWS: Codable {
    let id: String
    let roomID: Int
}

struct Location: Codable {
  let latitude: Double
  let longitude: Double
}

struct MessageRoomForm: Codable {
  let from: String
  let to: String
}


let host = ip

final class WebServices {
  static let baseURL = "http://\(host)/"
  
  static let createURL = URL(string: baseURL + "create/")!
  static let updateURL = URL(string: baseURL + "update/")!
  static let closeURL = URL(string: baseURL + "close/")!
    // notify
      static func create(
      success: @escaping (TrackingSession) -> Void,
      failure: @escaping (Error) -> Void
      ) {
        let reqURL = URL(string: baseURL + "create/\(String(describing: Auth.currentUserID))")
        var request = URLRequest(url: reqURL!) // createURL
      request.httpMethod = "POST"
      URLSession.shared.objectRequest(with: request, success: success, failure: failure)
    }
    
    // chat
    static func createChatWS(_ from: String, _ to: String,
    success: @escaping (TrackingSession) -> Void,
    failure: @escaping (Error) -> Void
    ) {
        do {
        let reqURL = URL(string: baseURL + "createChatWS/")
        let roomForm = MessageRoomForm(from: from, to: to)
    var request = URLRequest(url: reqURL!) // createURL
    request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(roomForm)
    URLSession.shared.objectRequest(with: request, success: success, failure: failure)
        } catch {
            
        }
  }
  
  static func update(
    _ message: DataMessage,
    for session: TrackingSession,
    completion: @escaping (Bool) -> Void
    ) {
    let url = updateURL.appendingPathComponent(session.data.id)
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    do {
      try request.addJSONBody(message)
    } catch {
      completion(false)
      return
    }
    
    URLSession.shared.dataRequest(
      with: request,
      success: { _ in completion(true) },
      failure: { _ in completion(false) }
    )
  }
  
  static func close(
    _ session: TrackingSession,
    completion: @escaping (Bool) -> Void
    ) {
    let url = closeURL.appendingPathComponent(String(session.data.id))
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    URLSession.shared.dataRequest(
      with: request,
      success: { _ in completion(true) },
      failure: { _ in completion(false) }
    )
  }
}

 

/// Copyright (c) 2021 Razeware LLC
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

import Vapor
//import LeafKit
//import SwiftMarkdown
//import cmark
//import Ink
import Markdown

struct WebsiteController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let authSessionsRoutes = routes.grouped(User.sessionAuthenticator())
    authSessionsRoutes.get("login", use: loginHandler)
    let credentialsAuthRoutes = authSessionsRoutes.grouped(User.credentialsAuthenticator())
    credentialsAuthRoutes.post("login", use: loginPostHandler)
    authSessionsRoutes.post("logout", use: logoutHandler)
    authSessionsRoutes.get("register", use: registerHandler)
    authSessionsRoutes.post("register", use: registerPostHandler)
    
    authSessionsRoutes.get(use: indexHandler)
    authSessionsRoutes.get("acronyms", ":acronymID", use: acronymHandler)
    authSessionsRoutes.get("users", ":userID", use: userHandler)
    authSessionsRoutes.get("users", use: allUsersHandler)
    authSessionsRoutes.get("categories", use: allCategoriesHandler)
    authSessionsRoutes.get("categories", ":categoryID", use: categoryHandler)
    authSessionsRoutes.get("testleaf", use: testleaf)
    
    let protectedRoutes = authSessionsRoutes.grouped(User.redirectMiddleware(path: "/login"))
    protectedRoutes.get("acronyms", "create", use: createAcronymHandler)
    protectedRoutes.post("acronyms", "create", use: createAcronymPostHandler)
    protectedRoutes.get("acronyms", ":acronymID", "edit", use: editAcronymHandler)
    protectedRoutes.post("acronyms", ":acronymID", "edit", use: editAcronymPostHandler)
    protectedRoutes.post("acronyms", ":acronymID", "delete", use: deleteAcronymHandler)
  }
    
    
    // Test rendering markdown.
    func testleaf (_ req: Request) throws -> EventLoopFuture<View> {
        let html: String
//        html = try markdownToHTMLTest(markdown)
        var parser = MarkdownParser()
        let modifier = Modifier(target: .headings) { html, markdown in
            return html
        }

        parser.addModifier(modifier)
        let html1 = parser.html(from: markdown)
        return req.view.render("hello", [
                                "name": "Leaf",
                                "md": html1
        ])
    }

    // Using cmark for parse markdown to html.
//    public enum MarkdownError: Error {
//        case conversionFailed
//    }
//
//    public struct MarkdownOptions: OptionSet {
//        public let rawValue: Int32
//
//        public init(rawValue: Int32) {
//            self.rawValue = rawValue
//        }
//
//        static public let sourcePosition = MarkdownOptions(rawValue: 1 << 1)
//        static public let hardBreaks = MarkdownOptions(rawValue: 1 << 2)
//        static public let safe = MarkdownOptions(rawValue: 1 << 3)
//        static public let noBreaks = MarkdownOptions(rawValue: 1 << 4)
//        static public let normalize = MarkdownOptions(rawValue: 1 << 8)
//        static public let validateUTF8 = MarkdownOptions(rawValue: 1 << 9)
//        static public let smartQuotes = MarkdownOptions(rawValue: 1 << 10)
//        static public let unsafe = MarkdownOptions(rawValue: 1 << 17)
//    }
//
//    public func markdownToHTMLTest(_ str: String, options: MarkdownOptions = [.safe]) throws -> String {
//        var buffer: String?
//        try str.withCString {
//
//            guard let buf = cmark_gfm_markdown_to_html($0, Int(strlen($0)), options.rawValue) else {
//                throw MarkdownError.conversionFailed
//            }
//            buffer = String(cString: buf)
//            free(buf)
//        }
//        guard let output = buffer else {
//            throw MarkdownError.conversionFailed
//        }
//        return output
//    }

    
    
  func indexHandler(_ req: Request) -> EventLoopFuture<View> {
    Acronym.query(on: req.db).all().flatMap { acronyms in
      let userLoggedIn = req.auth.has(User.self)
      let showCookieMessage = req.cookies["cookies-accepted"] == nil
      let context = IndexContext(title: "Home page", acronyms: acronyms, userLoggedIn: userLoggedIn, showCookieMessage: showCookieMessage)
      return req.view.render("index", context)
    }
  }
  
  func acronymHandler(_ req: Request) -> EventLoopFuture<View> {
    Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { acronym in
      let userFuture = acronym.$user.get(on: req.db)
      let categoriesFuture = acronym.$categories.query(on: req.db).all()
      return userFuture.and(categoriesFuture).flatMap { user, categories in
        let context = AcronymContext(
          title: acronym.short,
          acronym: acronym,
          user: user,
          categories: categories)
        return req.view.render("acronym", context)
      }
    }
  }
  
  func userHandler(_ req: Request) -> EventLoopFuture<View> {
    User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { user in
      user.$acronyms.get(on: req.db).flatMap { acronyms in
        let context = UserContext(title: user.name, user: user, acronyms: acronyms)
        return req.view.render("user", context)
      }
    }
  }
  
  func allUsersHandler(_ req: Request) -> EventLoopFuture<View> {
    User.query(on: req.db).all().flatMap { users in
      let context = AllUsersContext(
        title: "All Users",
        users: users)
      return req.view.render("allUsers", context)
    }
  }
  
  func allCategoriesHandler(_ req: Request) -> EventLoopFuture<View> {
    Category.query(on: req.db).all().flatMap { categories in
      let context = AllCategoriesContext(categories: categories)
      return req.view.render("allCategories", context)
    }
  }
  
  func categoryHandler(_ req: Request) -> EventLoopFuture<View> {
    Category.find(req.parameters.get("categoryID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { category in
      category.$acronyms.get(on: req.db).flatMap { acronyms in
        let context = CategoryContext(title: category.name, category: category, acronyms: acronyms)
        return req.view.render("category", context)
      }
    }
  }
  
  func createAcronymHandler(_ req: Request) -> EventLoopFuture<View> {
    let token = [UInt8].random(count: 16).base64
    let context = CreateAcronymContext(csrfToken: token)
    req.session.data["CSRF_TOKEN"] = token
    return req.view.render("createAcronym", context)
  }
  
  func createAcronymPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
    let data = try req.content.decode(CreateAcronymFormData.self)
    let user = try req.auth.require(User.self)
    
    let expectedToken = req.session.data["CSRF_TOKEN"]
    req.session.data["CSRF_TOKEN"] = nil
    guard 
      let csrfToken = data.csrfToken,
      expectedToken == csrfToken 
    else {
      throw Abort(.badRequest)
    }
    
    let acronym = try Acronym(short: data.short, long: data.long, userID: user.requireID())
    return acronym.save(on: req.db).flatMap {
      guard let id = acronym.id else {
        return req.eventLoop.future(error: Abort(.internalServerError))
      }
      var categorySaves: [EventLoopFuture<Void>] = []
      for category in data.categories ?? [] {
        categorySaves.append(Category.addCategory(category, to: acronym, on: req))
      }
      let redirect = req.redirect(to: "/acronyms/\(id)")
      return categorySaves.flatten(on: req.eventLoop).transform(to: redirect)
    }
  }
  
  func editAcronymHandler(_ req: Request) -> EventLoopFuture<View> {
    return Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { acronym in
      acronym.$categories.get(on: req.db).flatMap { categories in
        let context = EditAcronymContext(acronym: acronym, categories: categories)
        return req.view.render("createAcronym", context)
      }
    }
  }
  
  func editAcronymPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
    let user = try req.auth.require(User.self)
    let userID = try user.requireID()
    let updateData = try req.content.decode(CreateAcronymFormData.self)
    return Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { acronym in
      acronym.short = updateData.short
      acronym.long = updateData.long
      acronym.$user.id = userID
      guard let id = acronym.id else {
        return req.eventLoop.future(error: Abort(.internalServerError))
      }
      return acronym.save(on: req.db).flatMap {
        acronym.$categories.get(on: req.db)
      }.flatMap { existingCategories in
        let existingStringArray = existingCategories.map {
          $0.name
        }
        
        let existingSet = Set<String>(existingStringArray)
        let newSet = Set<String>(updateData.categories ?? [])
        
        let categoriesToAdd = newSet.subtracting(existingSet)
        let categoriesToRemove = existingSet.subtracting(newSet)
        
        var categoryResults: [EventLoopFuture<Void>] = []
        for newCategory in categoriesToAdd {
          categoryResults.append(Category.addCategory(newCategory, to: acronym, on: req))
        }
        
        for categoryNameToRemove in categoriesToRemove {
          let categoryToRemove = existingCategories.first {
            $0.name == categoryNameToRemove
          }
          if let category = categoryToRemove {
            categoryResults.append(
              acronym.$categories.detach(category, on: req.db))
          }
        }
        
        let redirect = req.redirect(to: "/acronyms/\(id)")
        return categoryResults.flatten(on: req.eventLoop).transform(to: redirect)
      }
    }
  }
  
  func deleteAcronymHandler(_ req: Request) -> EventLoopFuture<Response> {
    Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { acronym in
      acronym.delete(on: req.db).transform(to: req.redirect(to: "/"))
    }
  }
  
  func loginHandler(_ req: Request) -> EventLoopFuture<View> {
    let context: LoginContext
    if let error = req.query[Bool.self, at: "error"], error {
      context = LoginContext(loginError: true)
    } else {
      context = LoginContext()
    }
    return req.view.render("login", context)
  }
  
  func loginPostHandler(_ req: Request) -> EventLoopFuture<Response> {
    if req.auth.has(User.self) {
      return req.eventLoop.future(req.redirect(to: "/"))
    } else {
      let context = LoginContext(loginError: true)
      return req.view.render("login", context).encodeResponse(for: req)
    }
  }
  
  func logoutHandler(_ req: Request) -> Response {
    req.auth.logout(User.self)
    return req.redirect(to: "/")
  }
  
  func registerHandler(_ req: Request) -> EventLoopFuture<View> {
    let context: RegisterContext
    if let message = req.query[String.self, at: "message"] {
      context = RegisterContext(message: message)
    } else {
      context = RegisterContext()
    }
    return req.view.render("register", context)
  }
  
  func registerPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
    do {
      try RegisterData.validate(content: req)
    } catch let error as ValidationsError {
      let message = error.description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Unknown error"
      return req.eventLoop.future(req.redirect(to: "/register?message=\(message)"))
    }
    let data = try req.content.decode(RegisterData.self)
    let password = try Bcrypt.hash(data.password)
    let user = User(
      name: data.name,
      username: data.username,
      password: password)
    return user.save(on: req.db).map {
      req.auth.login(user)
      return req.redirect(to: "/")
    }
  }
}

struct IndexContext: Encodable {
  let title: String
  let acronyms: [Acronym]
  let userLoggedIn: Bool
  let showCookieMessage: Bool
}

struct AcronymContext: Encodable {
  let title: String
  let acronym: Acronym
  let user: User
  let categories: [Category]
}

struct UserContext: Encodable {
  let title: String
  let user: User
  let acronyms: [Acronym]
}

struct AllUsersContext: Encodable {
  let title: String
  let users: [User]
}

struct AllCategoriesContext: Encodable {
  let title = "All Categories"
  let categories: [Category]
}

struct CategoryContext: Encodable {
  let title: String
  let category: Category
  let acronyms: [Acronym]
}

struct CreateAcronymContext: Encodable {
  let title = "Create An Acronym"
  let csrfToken: String
}

struct EditAcronymContext: Encodable {
  let title = "Edit Acronym"
  let acronym: Acronym
  let editing = true
  let categories: [Category]
}

struct CreateAcronymFormData: Content {
  let short: String
  let long: String
  let categories: [String]?
  let csrfToken: String?
}

struct LoginContext: Encodable {
  let title = "Log In"
  let loginError: Bool
  
  init(loginError: Bool = false) {
    self.loginError = loginError
  }
}

struct RegisterContext: Encodable {
  let title = "Register"
  let message: String?

  init(message: String? = nil) {
    self.message = message
  }
}

struct RegisterData: Content {
  let name: String
  let username: String
  let password: String
  let confirmPassword: String
}

extension RegisterData: Validatable {
  public static func validations(_ validations: inout Validations) {
    validations.add("name", as: String.self, is: .ascii)
    validations.add("username", as: String.self, is: .alphanumeric && .count(3...))
    validations.add("password", as: String.self, is: .count(8...))
    validations.add("zipCode", as: String.self, is: .zipCode, required: false)
  }
}

extension ValidatorResults {
  struct ZipCode {
    let isValidZipCode: Bool
  }
}

extension ValidatorResults.ZipCode: ValidatorResult {
  var isFailure: Bool {
    !isValidZipCode
  }

  var successDescription: String? {
    "is a valid zip code"
  }

  var failureDescription: String? {
    "is not a valid zip code"
  }
}

extension Validator where T == String {
  private static var zipCodeRegex: String {
    "^\\d{5}(?:[-\\s]\\d{4})?$"
  }

  public static var zipCode: Validator<T> {
    Validator { input -> ValidatorResult in
      guard
        let range = input.range(of: zipCodeRegex, options: [.regularExpression]),
        range.lowerBound == input.startIndex && range.upperBound == input.endIndex
      else {
        return ValidatorResults.ZipCode(isValidZipCode: false)
      }
      return ValidatorResults.ZipCode(isValidZipCode: true)
    }
  }
}

let markdown = """
# RecordFastProject iOS

<h3 align="center">
  <img width="200px" src="https://user-images.githubusercontent.com/55421234/110569031-80b6da80-8186-11eb-8a8a-5eef2a5e22a2.gif">
  <img width="200px" src="https://cdn.dribbble.com/users/45617/screenshots/12910101/media/c170a9a4d64ad4dff24bac58529d26bb.png">
</h3>

# When use?
+ **For iOS developer reference purpose only. (learning how to make a recorder app, and config the output)**
+ This project help you record superfast by my custom and support text you will record show on screen with .csv file.
+ Using to making data to train model.

# Feature
+ Record into .wav extension by default (custom output extension in source).
+ Some specification are set for Audio format in this project **(you can config output type as anything you want - add, remove, fix value of any specification for a Audio format in source)**:
> AVFormatIDKey: Int(kAudioFormatLinearPCM)
> AVSampleRateKey: 16000
> AVNumberOfChannelsKey: 1
> AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
> AVLinearPCMBitDepthKey: 32
+ Record with low latency.
+ Show text to read. Change content in .csv file.
+ Auto increment name output file.
+ Just for fast record so cannot play recorded file, access the file manager on iphone to play your record.

# How fast?
> Tested **record and save 10 .wav file** with **12-15 word** per file in just **1 minute**.
> No crash, low latency.

# Prerequisite
> + A iOS developer to understand and custom this.

# How to build?
1. Clone project and open.
2. Switch to your account development in xcode.
3. Add content to record in csv file.
4. Build and run.

# Where output saved?
> + Output is saved in document folder of this app in file manager on iPhone.
> # How to take data?
> + Method 1: Connect to a MacOS PC.
> + Method 2: Access file manager on iPhone and upload to anywhere you want.

# Config output quality
> + This project record and extract .wav file.
> + Depend on your required output, config quality or type of output in code. **You control your output**, remmember that!

 `MarkdownParser`
```swift
.target(
    name: "App",
    dependencies: [
        // ...
        "LeafMarkdown"
    ],
    // ...
)
```
<p align="center">
    <a href="http://www.raywenderlich.com/">
        <img src="https://user-images.githubusercontent.com/9938337/51800584-21591300-2229-11e9-85f6-33d1203ee095.png" width="200" alt="raywenderlich.com">
    </a>
    <br>
    <br>
    <img src="https://user-images.githubusercontent.com/9938337/38052269-98e07e8c-32c8-11e8-9f63-7cec8cee742e.png" alt="TIL Application">
</p>

# Vapor TIL

This is the Vapor TIL (Today I Learned) application that is used throughout the [Server Side Swift with Vapor](https://store.raywenderlich.com/products/server-side-swift-with-vapor) book. The first sections of the book take you through everything you need to know to get started with Vapor. This application is deployed to Vapor Cloud, Heroku, Docker and AWS, using this repository!

In the book, you'll learn how to build routes and use Fluent to interact with a database. You'll learn how to create dynamic websites with Leaf and authenticate APIs, websites and validate fields. The 2nd half of the book goes into more advanced topics, including WebSockets, caching and microservices.

## Like what you see?

<p align="center">
  <a href="https://store.raywenderlich.com/products/server-side-swift-with-vapor">
    <img src="https://koenig-media.raywenderlich.com/uploads/2018/02/cover-vapor.png" alt="Server Side Swift with Vapor Book">
  </a>
</p>

The book is available on the [raywenderlich.com store](https://store.raywenderlich.com/products/server-side-swift-with-vapor).

## Video Course

<p align="center">
  <a href="https://videos.raywenderlich.com/courses/115-server-side-swift-with-vapor/lessons/1">
    <img src="https://koenig-media.raywenderlich.com/uploads/2018/02/Vapor_Screenshot_1-650x366.jpg" alt="Video Course">
  </a>
</p>

The video course is available to raywenderlich.com subscribers, which can be [watched here](https://videos.raywenderlich.com/courses/115-server-side-swift-with-vapor/lessons/1).

There are 30 videos covering:

* Getting Started
* Using Fluent
* Controllers
* Configuring Databases with MySQL
* Templating with Leaf
* API Authentication
* Web Authentication



# Leaf Markdown

[![Language](https://img.shields.io/badge/Swift-5.2-brightgreen.svg)](http://swift.org)
[![Build Status](https://github.com/vapor-community/leaf-markdown/workflows/CI/badge.svg?branch=main)](https://github.com/vapor-community/leaf-markdown/actions)
[![codecov](https://codecov.io/gh/vapor-community/leaf-markdown/branch/main/graph/badge.svg)](https://codecov.io/gh/vapor-community/leaf-markdown)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/vapor-community/leaf-markdown/main/LICENSE)

A Markdown renderer for Vapor and Leaf. This uses the [Vapor Markdown](https://github.com/vapor/markdown) package to wrap [cmark](https://github.com/github/cmark-gfm) (though a [fork](https://github.com/brokenhandsio/cmark-gfm) is used to make it work with Swift PM), so it understands [Common Mark](http://commonmark.org). A quick reference guide for Common Mark can be found [here](http://commonmark.org/help/). It also supports [Github Flavored Markdown](https://guides.github.com/features/mastering-markdown/).

## Usage

Once set up, you can use it in your Leaf template files like any other tag:

```swift
#markdown(myMarkdown)
```

Where you have passed `myMarkdown` into the view as something like:

```markdown
# Hey #

Check out my *awesome* markdown! It is easy to use in `tags`
```

## Setup

### Add as dependency

Add Leaf Markdown as a dependency in your `Package.swift` file:

```swift
    dependencies: [
        ...,
        .package(name: "LeafMarkdown", url: "https://github.com/vapor-community/leaf-markdown.git", .upToNextMajor(from: "3.0.0")),
    ]
```

Then add the dependency to your target:

```swift
.target(
    name: "App",
    dependencies: [
        // ...
        "LeafMarkdown"
    ],
    // ...
)
```

### Register with Leaf

Register the tag with Leaf so Leaf knows about it:

```swift
app.leaf.tags["markdown"] = Markdown()
```

Don't forget to import LeafMarkdown in the file you register the tag with `import LeafMarkdown`.


<p align="center">
    <img src="Logo.png" width="278" max-width="90%" alt=“Ink” />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.1-orange.svg" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/swiftpm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
     <img src="https://img.shields.io/badge/platforms-mac+linux-brightgreen.svg?style=flat" alt="Mac + Linux" />
    <a href="https://twitter.com/johnsundell">
        <img src="https://img.shields.io/badge/twitter-@johnsundell-blue.svg?style=flat" alt="Twitter: @johnsundell" />
    </a>
</p>

> Welcome to **Ink**, a fast and flexible Markdown parser written in Swift. It can be used to convert Markdown-formatted strings into HTML, and also supports metadata parsing, as well as powerful customization options for fine-grained post-processing. It was built with a focus on Swift-based web development and other HTML-centered workflows.

> Ink is used to render all articles on ## [swiftbysundell.com](https://swiftbysundell.com).

> ```swift
import Ink

let markdown: String = ...
let parser = MarkdownParser()
let html = parser.html(from: markdown)
```

## Converting Markdown into HTML

To get started with Ink, all you have to do is to import it, and use its `MarkdownParser` type to convert any Markdown string into efficiently rendered HTML:

```swift
import Ink

let markdown: String = ...
let parser = MarkdownParser()
let html = parser.html(from: markdown)
```

> That’s it! The resulting HTML can then be displayed as-is, or embedded into some other context — and if that’s all you need Ink for, then no more code is required.

## Automatic metadata parsing

Ink also comes with metadata support built-in, meaning that you can define key/value pairs at the top of any Markdown document, which will then be automatically parsed into a Swift dictionary.

To take advantage of that feature, call the `parse` method on `MarkdownParser`, which gives you a `Markdown` value that both contains any metadata found within the parsed Markdown string, as well as its HTML representation:

```swift
<p style="color:red;">let</p> markdown: String = ...
let parser = MarkdownParser()
let result = parser.parse(markdown)

let dateString = result.metadata["date"]
let html = result.html
```
<span><span style="color:red;">let</span> markdown: String = ...</span>
let parser = MarkdownParser()
let result = parser.parse(markdown)

let dateString = result.metadata["date"]
let html = result.html

To define metadata values within a Markdown document, use the following syntax:
-------
```
---
keyA: valueA
keyB: valueB
---

Markdown text...
```

The above format is also supported by many different Markdown editors and other tools, even though it’s not part of the [original Markdown spec](https://daringfireball.net/projects/markdown).

## Powerful customization

Besides its [built-in parsing rules](#markdown-syntax-supported), which aims to cover the most common features found in the various flavors of Markdown, you can also customize how Ink performs its parsing through the use of *modifiers*.

A modifier is defined using the `Modifier` type, and is associated with a given `Target`, which determines the kind of Markdown fragments that it will be used for. For example, here’s how an H3 tag could be added before each code block:

```swift
var parser = MarkdownParser()

let modifier = Modifier(target: .codeBlocks) { html, markdown in
    return "<h3>This is a code block:</h3>" + html
}

parser.addModifier(modifier)

let markdown: String = ...
let html = parser.html(from: markdown)
```

Modifiers are passed both the HTML that Ink generated for the given fragment, and its raw Markdown representation as well — both of which can be used to determine how each fragment should be customized.

## Performance built-in

Ink was designed to be as fast and efficient as possible, to enable hundreds of full-length Markdown articles to be parsed in a matter of seconds, while still offering a fully customizable API as well. Two key characteristics make this possible:

1. Ink aims to get as close to `O(N)` complexity as possible, by minimizing the amount of times it needs to read the Markdown strings that are passed to it, and by optimizing its HTML rendering to be completely linear. While *true* `O(N)` complexity is impossible to achieve when it comes to Markdown parsing, because of its very flexible syntax, the goal is to come as close to that target as possible.
2. A high degree of memory efficiency is achieved thanks to Swift’s powerful `String` API, which Ink makes full use of — by using string indexes, ranges and substrings, rather than performing unnecessary string copying between its various operations.

## Installation

Ink is distributed using the [Swift Package Manager](https://swift.org/package-manager). To install it into a project, simply add it as a dependency within your `Package.swift` manifest:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/johnsundell/ink.git", from: "0.1.0")
    ],
    ...
)
```

Then import Ink wherever you’d like to use it:

```swift
import Ink
```

For more information on how to use the Swift Package Manager, check out [this article](https://www.swiftbysundell.com/articles/managing-dependencies-using-the-swift-package-manager), or [its official documentation](https://github.com/apple/swift-package-manager/tree/master/Documentation).

## Command line tool

Ink also ships with a simple but useful command line tool that lets you convert Markdown to HTML directly from the command line.

To install it, clone the project and run `make`:

```
$ git clone https://github.com/johnsundell/Ink.git
$ cd Ink
$ make
```

The command line tool will be installed as `ink`, and can be passed Markdown text for conversion into HTML in several ways.

Calling it without arguments will start reading from `stdin` until terminated with `Ctrl+D`:

```
$ ink
```

Markdown text can be piped in when `ink` is called without arguments:

```
$ echo "*Hello World*" | ink
```

A single argument is treated as a filename, and the corresponding file will be parsed:

```
$ ink file.md
```

A Markdown string can be passed directly using the `-m` or `--markdown` flag:

```
$ ink -m "*Hello World*"
```

You can of course also build your own command line tools that utilizes Ink in more advanced ways by importing it as a package.

## Markdown syntax supported

Ink supports the following Markdown features:

- Headings (H1 - H6), using leading pound signs, for example `## H2`.
- Italic text, by surrounding a piece of text with either an asterisk (`*`), or an underscore (`_`). For example `*Italic text*`.
- Bold text, by surrounding a piece of text with either two asterisks (`**`), or two underscores (`__`). For example `**Bold text**`.
- Text strikethrough, by surrounding a piece of text with two tildes (`~~`), for example `~~Strikethrough text~~`.
- Inline code, marked with a backtick on either site of the code.
- Code blocks, marked with three or more backticks both above and below the block.
- Links, using the following syntax: `[Title](url)`.
- Images, using the following syntax: `![Alt text](image-url)`.
- Both images and links can also use reference URLs, which can be defined anywhere in a Markdown document using this syntax: `[referenceName]: url`.
- Both ordered lists (using numbers followed by a period (`.`) or right parenthesis (`)`) as bullets) and unordered lists (using either a dash (`-`), plus (`+`), or asterisk (`*`) as bullets) are supported.
- Ordered lists start from the index of the first entry
- Nested lists are supported as well, by indenting any part of a list that should be nested within its parent.
- Horizontal lines can be placed using either three asterisks (`***`) or three dashes (`---`) on a new line.
- HTML can be inlined both at the root level, and within text paragraphs.
- Blockquotes can be created by placing a greater-than arrow at the start of a line, like this: `> This is a blockquote`.
- Tables can be created using the following syntax (the line consisting of dashes (`-`) can be omitted to create a table without a header row):
```
| Header | Header 2 |
| ------ | -------- |
| Row 1  | Cell 1   |
| Row 2  | Cell 2   |
```

Please note that, being a very young implementation, Ink does not fully support all Markdown specs, such as [CommonMark](https://commonmark.org). Ink definitely aims to cover as much ground as possible, and to include support for the most commonly used Markdown features, but if complete CommonMark compatibility is what you’re looking for — then you might want to check out tools like [CMark](https://github.com/commonmark/cmark).

## Internal architecture

Ink uses a highly modular [rule-based](https://www.swiftbysundell.com/articles/rule-based-logic-in-swift) internal architecture, to enable new rules and formatting options to be added without impacting the system as a whole.

Each Markdown fragment is individually parsed and rendered by a type conforming to the internal `Readable` and `HTMLConvertible` protocols — such as `FormattedText`, `List`, and `Image`.

To parse a part of a Markdown document, each fragment type uses a `Reader` instance to read the Markdown string, and to make assertions about its structure. Errors are [used as control flow](https://www.swiftbysundell.com/articles/using-errors-as-control-flow-in-swift) to signal whether a parsing operation was successful or not, which in turn enables the parent context to decide whether to advance the current `Reader` instance, or whether to rewind it.

A good place to start exploring Ink’s implementation is to look at the main `MarkdownParser` type’s `parse` method, and to then dive deeper into the various `Fragment` implementations, and the `Reader` type.

## Credits

Ink was originally written by [John Sundell](https://twitter.com/johnsundell) as part of the Publish suite of static site generation tools, which is used to build and generate [Swift by Sundell](https://swiftbysundell.com). The other tools that make up the Publish suite will also be open sourced soon.

The Markdown format was created by [John Gruber](https://twitter.com/gruber). You can find [more information about it here](https://daringfireball.net/projects/markdown).

## Contributions and support

Ink is developed completely in the open, and your contributions are more than welcome.

Before you start using Ink in any of your projects, it’s highly recommended that you spend a few minutes familiarizing yourself with its documentation and internal implementation, so that you’ll be ready to tackle any issues or edge cases that you might encounter.

Since this is a very young project, it’s likely to have many limitations and missing features, which is something that can really only be discovered and addressed as more people start using it. While Ink is used in production to render all of [Swift by Sundell](https://swiftbysundell.com), it’s recommended that you first try it out for your specific use case, to make sure it supports the features that you need.

This project does not come with GitHub Issues-based support, and users are instead encouraged to become active participants in its continued development — by fixing any bugs that they encounter, or by improving the documentation wherever it’s found to be lacking.

If you wish to make a change, [open a Pull Request](https://github.com/JohnSundell/Ink/pull/new) — even if it just contains a draft of the changes you’re planning, or a test that reproduces an issue — and we can discuss it further from there.

Hope you’ll enjoy using **Ink**!

"""

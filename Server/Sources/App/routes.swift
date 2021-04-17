import Fluent
import Vapor
import Leaf

// MongoDB
import MongoKitten
import JWTKit

func routes(_ app: Application) throws {
    
    
    
    // MARK: - TIL.
    
    let acronymsController = AcronymsController()
    try app.register(collection: acronymsController)
    
    let usersController = UsersController()
    try app.register(collection: usersController)
    
    let categoriesController = CategoriesController()
    try app.register(collection: categoriesController)

    let websiteController = WebsiteController()
    try app.register(collection: websiteController)
    
    try app.register(collection: TodoController())
    
    // MARK: - Configure.
    // Increases the streaming body collection limit to 500kb
    app.routes.defaultMaxBodySize = "500kb"
//    app.routes.caseInsensitive = true // Distinguish between lower case and upper case - default is `false`
    
    // Collects streaming bodies (up to 1mb in size) before calling this route.
//    app.on(.POST, "listings", body: .collect(maxSize: "1mb")) { req in
//        // Handle request.
//    }
    
    // MARK: - Custom Encoder, Decoder.
    // Calls to encoding and decoding methods like req.content.decode support passing in custom coders for one-off usages.
    // create a new JSON decoder that uses unix-timestamp dates
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    // decodes Hello struct using custom decoder
//    let hello = try req.content.decode(Hello.self, using: decoder) // using
    
    // MARK: - Basic sample.
    // Route with description (Metadata)
//    app.get { req in
//        return req.view.render("index", ["title": "Hello Vapor!"])
//    }.description("says hello")

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    // Method 1.
//    app.get("hello", "vapor") { req in
//        return "Hello, vapor!"
//    }
    // Method 2.
    app.on(.GET, "hello", "vapor") { req in
        return "Hello, vapor!"
    }
    
    // responds to GET /hello/foo
    // responds to GET /hello/bar
    // ...
    app.get("hello", ":name") { req -> String in
        let name = req.parameters.get("name")!
        return "Hello, \(name)!"
    }
    
    // responds to GET /foo/bar/baz
    // responds to GET /foo/qux/baz
    // ...
    app.get("foo", "*", "baz") { req in
        return ""
    }
    
    // responds to GET /foo/bar
    // responds to GET /foo/bar/baz
    // ...
    app.get("foo", "**") { req in
        return ""
    }
    
    app.get("foo") { req -> String in
        return "bar"
    }
    
    // responds to GET /number/42
    // responds to GET /number/1337
    // ...
    app.get("number", ":x") { req -> String in
        guard let int = req.parameters.get("x", as: Int.self) else {
            throw Abort(.badRequest)
        }
        return "\(int) is a great number"
    }
    
    // responds to GET /hello/foo
    // responds to GET /hello/foo/bar
    // ...
    app.get("hello", "**") { req -> String in
        let name = req.parameters.getCatchall().joined(separator: " ")
        return "Hello, \(name)!"
    }
    
    // MARK: - Route Groups.
    // Method 1
//    let users = app.grouped("users")
//    // GET /users
//    users.get { req in
//        ...
//    }
//    // POST /users
//    users.post { req in
//        ...
//    }
//    // GET /users/:id
//    users.get(":id") { req in
//        let id = req.parameters.get("id")!
//        ...
//    }
    
    // Method 2
//    app.group("users") { users in
//        // GET /users
//        users.get { req in
//            ...
//        }
//        // POST /users
//        users.post { req in
//            ...
//        }
//        // GET /users/:id
//        users.get(":id") { req in
//            let id = req.parameters.get("id")!
//            ...
//        }
//    }
    
    // Method 3: Nesting path prefixing route groups.
//    app.group("users") { users in
//        // GET /users
//        users.get { ... }
//        // POST /users
//        users.post { ... }
//
//        users.group(":id") { user in
//            // GET /users/:id
//            user.get { ... }
//            // PATCH /users/:id
//            user.patch { ... }
//            // PUT /users/:id
//            user.put { ... }
//        }
//    }
    
    // Method 4: Middleware.
//    app.get("fast-thing") { req in
//        ...
//    }
//    app.group(RateLimitMiddleware(requestsPerMinute: 5)) { rateLimited in
//        rateLimited.get("slow-thing") { req in
//            ...
//        }
//    }
    
    // MARK: - Redirections.
//    req.redirect(to: "/some/new/path")
    // Specify the type of redirect, for example to redirect a page permanently (so that your SEO is updated correctly).
//    req.redirect(to: "/some/new/path", type: .permanent)
    
    // MARK: - Decoding URL query string
    // /hello?name=Vapor
    app.get("hello") { req -> String in
        let hello = try req.query.decode(Hello.self)
//        let name: String? = req.query["name"]
        return "Hello, \(hello.name ?? "Anonymous")"
    }
    struct Hello: Content {
        var name: String?
        
        // MARK: - Hook.
        // Vapor will automatically call beforeDecode and afterDecode on a Content type. Default implementations are provided which do nothing, but you can use these methods to run custom logic.
        // Runs after this Content is decoded. `mutating` is only required for structs, not classes.
        mutating func afterDecode() throws {
            // Name may not be passed in, but if it is, then it can't be an empty string.
            self.name = self.name?.trimmingCharacters(in: .whitespacesAndNewlines)
            if let name = self.name, name.isEmpty {
                throw Abort(.badRequest, reason: "Name must not be empty.")
            }
        }

        // Runs before this Content is encoded. `mutating` is only required for structs, not classes.
        mutating func beforeEncode() throws {
            // Have to *always* pass a name back, and it can't be an empty string.
            guard
                let name = self.name?.trimmingCharacters(in: .whitespacesAndNewlines),
                !name.isEmpty
            else {
                throw Abort(.badRequest, reason: "Name must not be empty.")
            }
            self.name = name
        }
    }
    
    app.get("testhtml") { _ in
        HTML(value: """
      <html>
        <body>
          <h1>Hello, World!</h1>
        </body>
      </html>
      """)
    }

}

// MARK: - Custom ResponseEncodable.
struct HTML {
    let value: String
}
extension HTML: ResponseEncodable {
    public func encodeResponse(for request: Request) -> EventLoopFuture<Response> {
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "text/html")
        return request.eventLoop.makeSucceededFuture(.init(
            status: .ok, headers: headers, body: .init(string: value)
        ))
    }
}
/* You can then use HTML as a response type in your routes:
 app.get { _ in
   HTML(value: """
   <html>
     <body>
       <h1>Hello, World!</h1>
     </body>
   </html>
   """)
 }
 */

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

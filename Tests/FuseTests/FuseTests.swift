//
//  FuseTests.swift
//  FuseTests
//
//  Created by Nicolas Degen on 19.03.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import XCTest

import DemoServer

@testable import Fuse

var testServer = DemoServer()

final class FuseTests: XCTestCase {
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.
    XCTAssertEqual(Fuse().text, "Hello, World!")
  }
  
  static var allTests = [
    ("testExample", testExample),
  ]
}

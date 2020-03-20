//
//  ServerBindingTests.swift
//  FuseTests
//
//  Created by Nicolas Degen on 20.03.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import XCTest

import DemoServer

@testable import Fuse

var testServer = DemoServer()

class ServerBindingTests: XCTestCase {
  
  @ServerBinding(server: testServer)
  var testData = TestData(id: "1", name: "1")
  
  func testSetter() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    let newName = "one"
    testServer.set(TestData(id: testData.id, name: newName))
    XCTAssert(testData.name == newName)
  }
}

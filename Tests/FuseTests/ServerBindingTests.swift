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

class TestClass {
  @ServerBinding(server: testServer)
  var testData = TestData(id: "1", name: "1")
}

class ServerBindingTests: XCTestCase {
  func testSetter() {
    let testClass = TestClass()
    XCTAssert(testClass.testData.name == "1")
    testServer.set(TestData(id: testClass.testData.id, name: "one"))
    XCTAssert(testClass.testData.name == "one")
  }
}

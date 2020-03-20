//
//  StorableTests.swift
//  FuseTests
//
//  Created by Nicolas Degen on 20.03.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import XCTest

import DemoServer

@testable import Fuse

class StorableTests: XCTestCase {
  
  var testData = TestData(id: "test_id", name: "TestName")
  var testTestData = TestTestData(id: "test_test_id", name: "TestTestName")
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  
  func testTypeName() {
    XCTAssert(type(of:testData).typeId == "test_typename")
    XCTAssert(getTypeId(testData) == "test")
    
    XCTAssert(type(of:testTestData).typeId == "test_test")
    XCTAssert(getTypeId(testTestData) == "test_test")
  }
}

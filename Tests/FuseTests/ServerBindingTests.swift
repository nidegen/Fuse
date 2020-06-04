//
//  FusingTests.swift
//  FuseTests
//
//  Created by Nicolas Degen on 20.03.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import XCTest

import Fuse


class TestClass: ObservableObject {
  @Fusing(server: testServer)
  var testData = TestData(id: "1", name: "1")
  
  @OptionalFusing(id: "sdf", server: testServer)
  var data: TestData?
}

class FusingTests: XCTestCase {
  func testSetter() {
    let testClass = TestClass()
    XCTAssert(testClass.testData.name == "1")
    testServer.set(TestData(id: testClass.testData.id, name: "one"))
    XCTAssert(testClass.testData.name == "one")
    testClass.testData.name = "ha"
    testServer.get(id: "1", ofDataType: TestData.self) { (data: Fusable?) in
      let test = data as? TestData
      XCTAssert(test?.name == "ha")
    }
  }
}

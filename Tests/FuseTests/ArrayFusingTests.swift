//
//  ArrayFusingTests.swift
//  FuseTests
//
//  Created by Nicolas Degen on 29.03.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import XCTest

@testable import Fuse


class TestArrayClass {
  @ArrayFusing(server: testServer, matching: [Constraint(whereDataField: "name", .isEqual(value: "Tom"))])
  var testData: [TestData]
}

class ArrayFusingTests: XCTestCase {
  override func setUp() {
    testServer.set([TestData(id: "a", name: "Peter"),
                    TestData(id: "b", name: "Mark"),
                    TestData(id: "c", name: "Tom"),
                    TestData(id: "d", name: "Peter"),
                    TestData(id: "e", name: "Carl"),
                    TestData(id: "f", name: "Nick"),
                    TestData(id: "g", name: "Peter"),
                    TestData(id: "h", name: "Tom")])
  }
  
  func testSetter() {
    let testClass = TestArrayClass()
    testServer.set(TestData(id: "i", name: "Tim"))
    XCTAssert(testClass.testData.count == 2)
  }
}

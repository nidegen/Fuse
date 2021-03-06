//
//  FusingTests.swift
//  FuseTests
//
//  Created by Nicolas Degen on 20.03.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import XCTest

@testable import Fuse


class TestClass: ObservableObject {
  @Fused(server: testServer, settingNew: true)
  var testData = TestData(id: "1", name: "1")
  
  @OptionalFuser(id: "1", server: testServer)
  var fuserTestData: TestData?
  
  @FusedOptional(id: "sdf", server: testServer)
  var data: TestData?
}

class FusingTests: XCTestCase {
  func testSetter() {
    let testClass = TestClass()
    XCTAssert(testClass.testData.name == "1")
    XCTAssert(testClass.fuserTestData?.name ?? "" == "1")
    testServer.set(TestData(id: testClass.testData.id, name: "one"))
    XCTAssert(testClass.testData.name == "one")
    testClass.testData.name = "ha"
    testServer.get(id: "1", ofDataType: TestData.self) { result in
      switch result {
      case .success(let data):
        let test = data as? TestData
        XCTAssert(test?.name == "ha")
      case .failure(let error):
        print(error.localizedDescription)
      }
    }
  }
}

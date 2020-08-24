//
//  DebugTests.swift
//  DebugTests
//
//  Created by Nicolas Degen on 19.03.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import XCTest
import Fuse
@testable import Debug

final class DebugServerTests: XCTestCase {
  
  var bindings = [BindingHandler]()
  
  override func setUp() {
  }
  
  func testSetStorable() {
    let server = DebugServer()
    server.set(TestData(id: "a", age: 12))
    XCTAssert(server.typeStore[TestData.typeId] != nil)
    XCTAssert(server.typeStore[TestData.typeId]?.count == 1)
  }
  
  func testSetTypesStorable() {
    let server = DebugServer()
    server.set(TestData(id: "a", age: 12))
    server.set(TestData(id: "b", age: 23))
    server.set(DemoTestData(id: "c", test: "12"))
    server.set(DemoTestData(id: "d", test: "34"))
    
    server.get(id: "a", ofDataType: DemoTestData.self) { data in
      XCTAssert(data == nil)
    }
    
    server.get(id: "c", ofDataType: DemoTestData.self) { data in
      guard let data = data as? DemoTestData else { XCTFail(); return }
      XCTAssert(type(of: data).typeId == "demo_test")
      XCTAssert(data.test == "12")
    }
    
    XCTAssert(server.typeStore[TestData.typeId] != nil)
    XCTAssert(server.typeStore[TestData.typeId]?.count == 2)
  }
  
  func testGetStorable() {
    let a = TestData(id: "a", age: 12)
    let b = TestData(id: "b", age: 122)
    let server = DebugServer()
    server.set(a)
    XCTAssert(server.typeStore[TestData.typeId]?.count == 1)
    
    server.set(b)
    XCTAssert(server.typeStore[TestData.typeId]?.count == 2)
    
    server.get(id: a.id) { (received: TestData?) in
      XCTAssert(received?.id == a.id)
      XCTAssert(received?.age == a.age)
    }
    server.get(ids: ["a", "b"]) { (data:[TestData]) in
      XCTAssert(data.contains(a))
      XCTAssert(data.contains(b))
    }
    XCTAssert(server.typeStore[TestData.typeId] != nil)
    XCTAssert(server.typeStore[TestData.typeId]?.count == 2)
  }
  
  func testBindStorable() {
    let expectation = XCTestExpectation(description: "Listen to change")
    let nonExpectation = XCTestExpectation(description: "Expect not to trigger")
    nonExpectation.isInverted = true
    var inbox = [TestData?]()
    let data = TestData(id: "a", age: 12)
    let server = DebugServer()
    bindings += [server.bind(toId: "a") { (received: TestData?) in
      inbox.append(received)
      if inbox.count == 3 {
        expectation.fulfill()
      } else if inbox.count > 3 {
        nonExpectation.fulfill()
      }
    }]
    
    server.set(data)
    server.set(data)
    server.set(TestData(id: "a", age: 33))
  }
  
  func testBindWhere() {
    let expectation = XCTestExpectation(description: "Listen to change")
    let a = TestData(id: "a", age: 12)
    let b = TestData(id: "b", age: 13)
    let c = TestData(id: "c", age: 12)
    let d = TestData(id: "d", age: 14)
    let server = DebugServer()
    server.set([a,b,c,d])
    bindings += [server.bind(whereDataField: "age", isEqualTo: 12) { (data: [TestData]) in
      XCTAssert(data.count == 2)
      expectation.fulfill()
    }]
    server.set(TestData(id: "e", age: 1))
  }
}

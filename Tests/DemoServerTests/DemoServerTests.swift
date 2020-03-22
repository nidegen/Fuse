//
//  DemoServerTests.swift
//  DemoServerTests
//
//  Created by Nicolas Degen on 19.03.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import XCTest
import Fuse
@testable import DemoServer

final class DemoServerTests: XCTestCase {
  
  
  override func setUp() {
  }
  
  func testSetStorable() {
    let server = DemoServer()
    server.set(DemoData(id: "a", age: 12))
    XCTAssert(server.typeStore[DemoData.typeId] != nil)
    XCTAssert(server.typeStore[DemoData.typeId]?.count == 1)
  }
  
  func testSetTypesStorable() {
    let server = DemoServer()
    server.set(DemoData(id: "a", age: 12))
    server.set(DemoData(id: "b", age: 23))
    server.set(DemoDemoData(id: "c", test: "12"))
    server.set(DemoDemoData(id: "d", test: "34"))
    
    server.get(id: "a", ofDataType: DemoDemoData.self) { data in
      XCTAssert(data == nil)
    }
    
    server.get(id: "c", ofDataType: DemoDemoData.self) { data in
      guard let data = data as? DemoDemoData else { XCTFail(); return }
      XCTAssert(type(of: data).typeId == "demo_demo")
      XCTAssert(data.test == "12")
    }
    
    XCTAssert(server.typeStore[DemoData.typeId] != nil)
    XCTAssert(server.typeStore[DemoData.typeId]?.count == 2)
  }
  
  func testGetStorable() {
    let data = DemoData(id: "a", age: 12)
    let server = DemoServer()
    server.set(data)
    server.get(id: data.id) { (received: DemoData?) in
      XCTAssert(received?.id == data.id)
      XCTAssert(received?.age == data.age)
    }
    XCTAssert(server.typeStore[DemoData.typeId] != nil)
    XCTAssert(server.typeStore[DemoData.typeId]?.count == 1)
  }
  
  func testBindStorable() {
    let expectation = XCTestExpectation(description: "Listen to change")
    var inbox = [DemoData?]()
    let data = DemoData(id: "a", age: 12)
    let server = DemoServer()
    let binding = server.bind(forId: "a") { (received: DemoData?) in
      inbox.append(received)
      if inbox.count == 3 {
        expectation.fulfill()
      }
    }
    server.set(data)
    server.set(DemoData(id: "a", age: 33))
  }
}

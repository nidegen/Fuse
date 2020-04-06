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
    let a = DemoData(id: "a", age: 12)
    let b = DemoData(id: "b", age: 122)
    let server = DemoServer()
    server.set(a)
    XCTAssert(server.typeStore[DemoData.typeId]?.count == 1)
    
    server.set(b)
    XCTAssert(server.typeStore[DemoData.typeId]?.count == 2)
    
    server.get(id: a.id) { (received: DemoData?) in
      XCTAssert(received?.id == a.id)
      XCTAssert(received?.age == a.age)
    }
    server.get(ids: ["a", "b"]) { (data:[DemoData]) in
      XCTAssert(data.contains(a))
      XCTAssert(data.contains(b))
    }
    XCTAssert(server.typeStore[DemoData.typeId] != nil)
    XCTAssert(server.typeStore[DemoData.typeId]?.count == 2)
  }
  
  func testBindStorable() {
    let expectation = XCTestExpectation(description: "Listen to change")
    let nonExpectation = XCTestExpectation(description: "Expect not to trigger")
    nonExpectation.isInverted = true
    var inbox = [DemoData?]()
    let data = DemoData(id: "a", age: 12)
    let server = DemoServer()
    let binding = server.bind(toId: "a") { (received: DemoData?) in
      inbox.append(received)
      if inbox.count == 3 {
        expectation.fulfill()
      } else if inbox.count > 3 {
        nonExpectation.fulfill()
      }
    }
    server.set(data)
    server.set(data)
    server.set(DemoData(id: "a", age: 33))
  }
  
  func testBindWhere() {
    let expectation = XCTestExpectation(description: "Listen to change")
    let a = DemoData(id: "a", age: 12)
    let b = DemoData(id: "b", age: 13)
    let c = DemoData(id: "c", age: 12)
    let d = DemoData(id: "d", age: 14)
    let server = DemoServer()
    server.set([a,b,c,d])
    let binding = server.bind(whereDataField: "age", isEqualTo: 12) { (data: [DemoData]) in
      XCTAssert(data.count == 2)
      expectation.fulfill()
    }
    server.set(DemoData(id: "e", age: 1))
  }
}

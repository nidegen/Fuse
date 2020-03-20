//
//  DemoServerTests.swift
//  DemoServerTests
//
//  Created by Nicolas Degen on 19.03.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import XCTest
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
}

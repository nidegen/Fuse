//
//  FuseTests.swift
//  FuseTests
//
//  Created by Nicolas Degen on 19.03.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import XCTest
import FuseMock
@testable import Fuse

var testServer = MockServer()

final class FuseTests: XCTestCase {
  var server = testServer
  func testSetter() {
    let input = TestData(id: "input", name: "one")
    testServer.set(input)
    let output: TestData? = testServer.getSync(id: "input")
    XCTAssert(output?.name == input.name)
  }
}

//
//  TestData.swift
//  FuseTests
//
//  Created by Nicolas Degen on 20.03.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import Fuse

struct TestData: Fusable {
  let id: Id
  var name: String
  
  static var typeId: String {
    return "test_typename"
  }
}

struct TestTestData: Fusable {
  let id: Id
  var name: String
}

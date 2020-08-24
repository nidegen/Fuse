//
//  TestData.swift
//  DebugTests
//
//  Created by Nicolas Degen on 20.03.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import Fuse

public struct TestData: Fusable, Equatable {
  public var id: Id
  public var age = 0
}

public struct DemoTestData: Fusable {
  public var id: Id
  public var test = "test"
}


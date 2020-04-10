//
//  DemoData.swift
//  DemoServer
//
//  Created by Nicolas Degen on 20.03.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import Fuse

public struct DemoData: Fusable, Equatable {
  public var id: Id
  public var age = 0
}

public struct DemoDemoData: Fusable {
  public var id: Id
  public var test = "test"
}

extension Storable {
  public static var serverVersionString: String { "test" }

}


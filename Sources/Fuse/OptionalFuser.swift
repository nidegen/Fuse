//
//  OptionalFuser.swift
//  Fuse
//
//  Created by Nicolas Degen on 01.07.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import Foundation

@propertyWrapper
public class OptionalFuser<T:Fusable>: ObservableObject {
  var data: OptionalFusing<T>
    
  public init(id: Id, server: Server? = nil) {
    let server = server ?? DefaultServerContainer.server
    data = OptionalFusing(id: id, server: server)
    data.objectWillChange = self.objectWillChange
  }
  
  
  public var wrappedValue: T? {
    get {
      return data.wrappedValue
    }
    
    set {
      data.wrappedValue = newValue
    }
  }
}

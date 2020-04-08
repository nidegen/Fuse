//
//  ArrayServerBinding.swift
//  Fuse
//
//  Created by Nicolas Degen on 29.03.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import Combine

@propertyWrapper
public class ArrayServerBinding<T:Storable> {
  var data: [T]
  var observerHandle: BindingHandler!
  var server: Server
  
  var setIsInternal = false

  public init(wrappedValue value: [T], server: Server, whereDataField field: String, isEqualTo comparedValue: Any) {
    self.data = value
    self.server = server
    observerHandle = server.bind(whereDataField: field, isEqualTo: comparedValue, completion: callback)
  }
  
  func callback(update: [T]) {
    setIsInternal = true
    self.data = update
    setIsInternal = false
  }
  
  public var wrappedValue: [T] {
    get {
      return data
    }
    
    set {
      objectWillChange?.send()
      data = newValue
      if !setIsInternal {
        server.set(data)
      }
    }
  }

  public var objectWillChange: ObservableObjectPublisher?
}

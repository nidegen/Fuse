//
//  ArrayFusing.swift
//  Fuse
//
//  Created by Nicolas Degen on 29.03.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import Combine

@propertyWrapper
public class ArrayFusing<T:Fusable> {
  var data: [T]
  var observerHandle: BindingHandler!
  var server: Server
  
  public init(server: Server? = nil, whereDataField field: String, isEqualTo comparedValue: Any, publisher: ObservableObjectPublisher? = nil) {
    self.data = [T]()
    self.server = server ?? DefaultServerContainer.server
    observerHandle = self.server.bind(whereDataField: field, isEqualTo: comparedValue) { [weak self] (update: [T]) in
      self?.callback(update: update)
    }
    objectWillChange = publisher
  }
  
  public init(server: Server? = nil, ids: [Id], publisher: ObservableObjectPublisher? = nil) {
    self.data = [T]()
    self.server = server ?? DefaultServerContainer.server
    observerHandle = self.server.bind(toIds: ids) { [weak self] (update: [T]) in
      self?.callback(update: update)
    }
    objectWillChange = publisher
  }

  public init(server: Server? = nil, publisher: ObservableObjectPublisher? = nil) {
    self.data = [T]()
    self.server = server ?? DefaultServerContainer.server
    observerHandle = self.server.bind() { [weak self] (update: [T]) in
      self?.callback(update: update)
    }
    objectWillChange = publisher
  }

  public init(server: Server? = nil, whereDataField field: String, isContainedIn values: [Any], publisher: ObservableObjectPublisher? = nil) {
    self.data = [T]()
    self.server = server ?? DefaultServerContainer.server
    observerHandle = self.server.bind(whereDataField: field, isContainedIn: values) { [weak self] (update: [T]) in
      self?.callback(update: update)
    }
    objectWillChange = publisher
  }

  public init(server: Server? = nil, whereDataField field: String, contains comparedValue: Any, publisher: ObservableObjectPublisher? = nil) {
    self.data = [T]()
    self.server = server ?? DefaultServerContainer.server
    observerHandle = self.server.bind(whereDataField: field, contains: comparedValue) { [weak self] (update: [T]) in
      self?.callback(update: update)
    }
    objectWillChange = publisher
  }

  public init(_ option: FusingOption, server: Server? = nil) {
    self.server = server ?? DefaultServerContainer.server
    self.data = []
  }
  
  func callback(update: [T]) {
    self.objectWillChange?.send()
    self.data = update
  }
  
  public var wrappedValue: [T] {
    get {
      return data
    }
    
    set {
      objectWillChange?.send()
      data = newValue
      server.set(data)
    }
  }

  public var objectWillChange: ObservableObjectPublisher?
}

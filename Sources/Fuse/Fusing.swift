//
//  Fusing.swift
//  Fuse
//
//  Created by Nicolas Degen on 20.03.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import Combine

@propertyWrapper
public class Fusing<T:Fusable> {
  var data: T
  var observerHandle: BindingHandler!
  var server: Server
    
  public init(wrappedValue value: T, server: Server? = nil, publisher: ObservableObjectPublisher? = nil) {
    self.data = value
    self.server = server ?? DefaultServerContainer.server!
    self.observerHandle = self.server.bind(toId: value.id) { [weak self] (update: T?) in
      self?.callback(update: update)
    }
      
    self.objectWillChange = publisher
  }
  
  func callback(update: T?) {
    update.map {
      self.objectWillChange?.send()
      self.data = $0
    }
  }
  
  public var wrappedValue: T {
    get {
      return data
    }
    
    set {
      objectWillChange?.send()
      data = newValue
      server.set(data)
      publisher?.subject.value = newValue
    }
  }
  
  public struct Publisher: Combine.Publisher {
    
    public typealias Output = T
    
    public typealias Failure = Never
    
    public func receive<Downstream: Subscriber>(subscriber: Downstream)
      where Downstream.Input == T, Downstream.Failure == Never {
        subject.subscribe(subscriber)
    }
    
    fileprivate let subject: Combine.CurrentValueSubject<T, Never>
    
    fileprivate init(_ output: Output) {
      subject = .init(output)
    }
  }
  
  private var publisher: Publisher?
  
  public var objectWillChange: ObservableObjectPublisher?
  
  public var projectedValue: Publisher {
    get {
      if let publisher = publisher {
        return publisher
      }
      let publisher = Publisher(wrappedValue)
      self.publisher = publisher
      return publisher
    }
  }
  
  //  public static subscript<EnclosingSelf: ObservableObject>(
  //    _enclosingInstance object: EnclosingSelf,
  //    wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, T>,
  //    storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Self>
  //  ) -> T {
  //    get {
  //      if object[keyPath: storageKeyPath].objectWillChange == nil {
  //        object[keyPath: storageKeyPath].objectWillChange = object.objectWillChange as? ObservableObjectPublisher
  //      }
  //      return object[keyPath: storageKeyPath].wrappedValue
  //    }
  //    set {
  //      if object[keyPath: storageKeyPath].objectWillChange == nil {
  //        object[keyPath: storageKeyPath].objectWillChange = object.objectWillChange as? ObservableObjectPublisher
  //      }
  //      object[keyPath: storageKeyPath].objectWillChange?.send()
  //      object[keyPath: storageKeyPath].publisher?.subject.send(newValue)
  //      object[keyPath: storageKeyPath].wrappedValue = newValue
  //    }
  //  }
}

public enum FusingOption {
  case nilFusing
}

@propertyWrapper
public class OptionalFusing<T:Fusable> {
  var data: T?
  var observerHandle: BindingHandler!
  var server: Server!
  var id: Id!
  
  public init(id: Id, server: Server? = nil) {
    self.id = id
    self.server = server ?? DefaultServerContainer.server!
    self.observerHandle = self.server.bind(toId: id) { [weak self] (update: T?) in
      self?.callback(update: update)
    }
  }
  
  public init(_ data: T, server: Server? = nil) {
    self.id = data.id
    self.data = data
    self.server = server ?? DefaultServerContainer.server!
    self.observerHandle = self.server.bind(toId: id) { [weak self] (update: T?) in
      self?.callback(update: update)
    }
  }
  
  public init(_ option: FusingOption) {}
  
  func callback(update: T?) {
    self.objectWillChange?.send()
    self.data = update
  }
  
  public var wrappedValue: T? {
    get {
      return data
    }
    
    set {
      objectWillChange?.send()
      data = newValue
      if let data = data {
        server.set(data)
      } else {
        server.delete(id, forDataType: T.self) { error in
          print(error?.localizedDescription ?? "Error deleting value on server")
        }
      }
      publisher?.subject.value = newValue
    }
  }
  
  public struct Publisher: Combine.Publisher {
    
    public typealias Output = T?
    
    public typealias Failure = Never
    
    public func receive<Downstream: Subscriber>(subscriber: Downstream)
      where Downstream.Input == T?, Downstream.Failure == Never {
        subject.subscribe(subscriber)
    }
    
    fileprivate let subject: Combine.CurrentValueSubject<T?, Never>
    
    fileprivate init(_ output: Output) {
      subject = .init(output)
    }
  }
  
  private var publisher: Publisher?
  
  public var objectWillChange: ObservableObjectPublisher?
  
  public var projectedValue: Publisher {
    get {
      if let publisher = publisher {
        return publisher
      }
      let publisher = Publisher(wrappedValue)
      self.publisher = publisher
      return publisher
    }
  }
  
  //  public static subscript<EnclosingSelf: ObservableObject>(
  //    _enclosingInstance object: EnclosingSelf,
  //    wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, T>,
  //    storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Self>
  //  ) -> T {
  //    get {
  //      if object[keyPath: storageKeyPath].objectWillChange == nil {
  //        object[keyPath: storageKeyPath].objectWillChange = object.objectWillChange as? ObservableObjectPublisher
  //      }
  //      return object[keyPath: storageKeyPath].wrappedValue
  //    }
  //    set {
  //      if object[keyPath: storageKeyPath].objectWillChange == nil {
  //        object[keyPath: storageKeyPath].objectWillChange = object.objectWillChange as? ObservableObjectPublisher
  //      }
  //      object[keyPath: storageKeyPath].objectWillChange?.send()
  //      object[keyPath: storageKeyPath].publisher?.subject.send(newValue)
  //      object[keyPath: storageKeyPath].wrappedValue = newValue
  //    }
  //  }
}

//
//  Fusing.swift
//  Fuse
//
//  Created by Nicolas Degen on 20.03.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import Combine

@propertyWrapper
public class Fusing<T:Storable> {
  var data: T
  var observerHandle: BindingHandler!
  var server: Server
  
  var setIsInternal = false
  
  public init(wrappedValue value: T, server: Server, publisher:ObservableObjectPublisher? = nil) {
    self.data = value
    self.server = server
    self.observerHandle = server.bind(toId: value.id, completion: callback)
  }
  
  func callback(update: T?) {
    update.map {
      setIsInternal = true
      self.data = $0
      setIsInternal = false
    }
  }
  
  public var wrappedValue: T {
    get {
      return data
    }
    
    set {
      objectWillChange?.send()
      data = newValue
      if !setIsInternal {
        server.set(data)
      }
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

  internal var objectWillChange: ObservableObjectPublisher?

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


@propertyWrapper
public class OptionalFusing<T:Storable> {
  var data: T?
  var observerHandle: BindingHandler!
  var server: Server
  
  var setIsInternal = false
  var id: Id
    
  public init(id: Id, server: Server) {
    self.id = id
    self.server = server
    self.observerHandle = server.bind(toId: id, completion: callback)
  }
  
  func callback(update: T?) {
    setIsInternal = true
    self.data = update
    setIsInternal = false
  }
  
  public var wrappedValue: T? {
    get {
      return data
    }
    
    set {
      objectWillChange?.send()
      data = newValue
      if !setIsInternal {
        if let data = data {
          server.set(data)
        } else {
          server.delete(id, forDataType: T.self) { error in
            print(error?.localizedDescription ?? "Error deleting value on server")
          }
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

  internal var objectWillChange: ObservableObjectPublisher?

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

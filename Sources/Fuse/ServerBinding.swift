//
//  ServerBinding.swift
//  Fuse
//
//  Created by Nicolas Degen on 20.03.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import Combine

@propertyWrapper
class ServerBinding<T:Storable> {
  var data: T
  var observerHandle: BindingHandler!
  var server: DataServer
  
  init(wrappedValue value: T, server: DataServer) {
    self.data = value
    self.server = server
    self.observerHandle = server.bind(forId: value.id, completion: callback)
    #warning("This init is called twice. Why?")
  }
  
  func callback(update: T?) {
    update.map {
      self.data = $0
    }
  }
  
  public var wrappedValue: T {
    get {
      return data
    }
    
    set {
      data = newValue
      server.set(data)
//      objectWillChange?.send()
//      publisher?.subject.value = newValue
    }
  }
  
//  public struct Publisher: Combine.Publisher {
//
//    public typealias Output = T
//
//    public typealias Failure = Never
//
//    public func receive<Downstream: Subscriber>(subscriber: Downstream)
//      where Downstream.Input == T, Downstream.Failure == Never {
//        subject.subscribe(subscriber)
//    }
//
//    fileprivate let subject: Combine.CurrentValueSubject<T, Never>
//
//    fileprivate init(_ output: Output) {
//      subject = .init(output)
//    }
//  }
//
//  private var publisher: Publisher?
//
//  internal var objectWillChange: ObservableObjectPublisher?
//
//  public var projectedValue: Publisher {
//    get {
//      if let publisher = publisher {
//        return publisher
//      }
//      let publisher = Publisher(wrappedValue)
//      self.publisher = publisher
//      return publisher
//    }
//  }
  
  //  public static subscript<EnclosingSelf: AnyObject>(
  //      _enclosingInstance object: EnclosingSelf,
  //      wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, T>,
  //      storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Setting<T>>
  //  ) -> T {
  //      get {
  //          return object[keyPath: storageKeyPath].wrappedValue
  //      }
  //      set {
  //          object[keyPath: storageKeyPath].objectWillChange?.send()
  //          object[keyPath: storageKeyPath].publisher?.subject.send(newValue)
  //          object[keyPath: storageKeyPath].wrappedValue = newValue
  //      }
  //      // TODO: Benchmark and explore a possibility to use _modify
  //  }
}

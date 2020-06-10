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
  
  var didUpdate: ((T)->())?
    
  public init(wrappedValue value: T, server: Server? = nil, publisher: ObservableObjectPublisher? = nil, updatingServer: Bool = true) {
    self.data = value
    self.server = server ?? DefaultServerContainer.server
    if updatingServer {
      self.server.set(value)
    }
    self.observerHandle = self.server.bind(toId: value.id) { [weak self] (update: T?) in
      self?.callback(update: update)
    }
      
    self.objectWillChange = publisher
  }
  
  func callback(update: T?) {
    update.map {
      self.objectWillChange?.send()
      self.publisher?.subject.value = $0
      self.data = $0
      self.didUpdate?($0)
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
      didUpdate?(data)
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
  
 public static subscript<EnclosingSelf>(
   _enclosingInstance object: EnclosingSelf,
   wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, T>,
   storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Fusing<T>>
 ) -> T {
   get {
     if object[keyPath: storageKeyPath].objectWillChange == nil {
       object[keyPath: storageKeyPath].objectWillChange = getObservablePublisher(object)
     }
     return object[keyPath: storageKeyPath].wrappedValue
   }

   set {
     if object[keyPath: storageKeyPath].objectWillChange == nil {
       object[keyPath: storageKeyPath].objectWillChange = getObservablePublisher(object)
     }
     
     object[keyPath: storageKeyPath].objectWillChange?.send()

     object[keyPath: storageKeyPath].wrappedValue = newValue
   }
 }
}

func getObservablePublisher<T:ObservableObject>(_ observable: T) -> ObservableObjectPublisher? {
  return observable.objectWillChange as? ObservableObjectPublisher
}

func getObservablePublisher<T>(_ observable: T) -> ObservableObjectPublisher? {
  return nil
}

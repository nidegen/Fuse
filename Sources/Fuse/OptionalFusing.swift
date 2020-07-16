//
//  Fusing.swift
//  Fuse
//
//  Created by Nicolas Degen on 10.05.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import Combine

public enum FusingOption {
  case nilFusing
}

@propertyWrapper
public class OptionalFusing<T:Fusable> {
  var data: T?
  var observerHandle: BindingHandler!
  var server: Server
  var id: Id?
  
  public var didUpdate: ((T?)->())?
  
  public init(id: Id, server: Server? = nil) {
    self.id = id
    self.server = server ?? DefaultServerContainer.server
    self.observerHandle = self.server.bind(toId: id) { [weak self] (update: T?) in
      self?.callback(update: update)
    }
  }
  
  public init(_ data: T, server: Server? = nil, updatingServer: Bool = true) {
    self.server = server ?? DefaultServerContainer.server
    bindToData(data: data, updatingServer: updatingServer)
  }
  
  public init(_ option: FusingOption, server: Server? = nil) {
    self.server = server ?? DefaultServerContainer.server
  }
  
  func callback(update: T?) {
    self.objectWillChange?.send()
    self.publisher?.subject.value = update
    self.data = update
    self.didUpdate?(update)
  }
  
  func bindToData(data: T, updatingServer: Bool = true) {
    self.id = data.id
    self.data = data
    self.didUpdate?(data)
    if updatingServer {
      self.server.set(data, completion: nil)
    }
    self.observerHandle = self.server.bind(toId: data.id) { [weak self] (update: T?) in
      self?.callback(update: update)
    }
  }
  
  public var wrappedValue: T? {
    get {
      return data
    }
    
    set {
      objectWillChange?.send()
      publisher?.subject.value = newValue
      self.didUpdate?(newValue)
      
      if let data = newValue {
        if id == nil || id == data.id {
          if observerHandle == nil {
            bindToData(data: data)
          } else {
            self.server.set(data, completion: nil)
            self.data = data
          }
        } else {
          print("Error: Data with non-matching Id assigned to Optional Fusing. Ignoring")
          return
        }
      } else {
        data = nil
        observerHandle = nil
        if let id = self.id {
          server.delete(id, forDataType: T.self) { error in
            error.map { print($0.localizedDescription) }
          }
        }
        self.id = nil
      }
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

//
//  MockServer.swift
//  Fuse
//
//  Created by Nicolas Degen on 20.03.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import Foundation
import Fuse

public class MockBindingHandler: BindingHandler {
  private let id = UUID().uuidString
  
  var server: MockServer
  
  var typeId: Id = ""
  
  var valueCallback: (Fusable?) -> () = { data in }
  var arrayCallback: ([Fusable]) -> () = { data in }
  
  public func remove() {
    server.bindingHandlers.remove(self)
  }
  
  fileprivate init(server: MockServer) {
    self.server = server
  }
  
  var observedIds: [Id]?
  
  func updated(value: Fusable) {
    valueCallback(value)
  }
  
  func updated(values: [Fusable]) {
    arrayCallback(values)
  }
  
  deinit {
    remove()
  }
}

extension MockBindingHandler: Hashable {
  public static func == (lhs: MockBindingHandler, rhs: MockBindingHandler) -> Bool {
    lhs.id == rhs.id
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

public class MockServer: FuseServer {
  public init(){}
  
  var typeStore = [Id: [Id: Fusable]]()
  
  var bindingHandlers = Set<MockBindingHandler>()
  
  enum BindingTypes {
    case value, array, filteredArray, typedArray
  }
    
  public func set(_ storable: Fusable, completion: SetterCompletion = nil) {
    let typeId = type(of: storable).typeId
    if typeStore[typeId] == nil {
      let id = storable.id
      typeStore[typeId] = [id: storable]
    } else {
      typeStore[typeId]?[storable.id] = storable
    }
    let allUpdatedValues: [Fusable] = typeStore[typeId].map { $0.map { $1 } } ?? []
    bindingHandlers.forEach { $0.updated(values: allUpdatedValues)}
    bindingHandlers.forEach { $0.updated(value: storable)}
  }
  
  public func set(_ storables: [Fusable], completion: SetterCompletion = nil) {
    storables.forEach {
      self.set($0, completion: completion)
    }
  }
  
  public func delete(_ id: Id, forDataType type: Fusable.Type, completion: SetterCompletion = nil) {
    typeStore[type.typeId]?[id] = nil
  }
  
  public func get(id: Id, ofDataType type: Fusable.Type, completion: @escaping (Fusable?) -> ()) {
    let typeId = type.typeId
    let first = (typeStore[typeId]?.compactMap { return id == $0 ? $1 : nil } ?? []).first { $0.id == id }
    completion(first)
  }
  
  public func get(dataOfType type: Fusable.Type, matching constraints: [Constraint], completion: @escaping ([Fusable]) -> ()) {
    let fusable: [Fusable] = typeStore[type.typeId]?.compactMap { return $1} ?? []
    completion(fusable.filter { $0.matches(constraints) })
  }
  
  public func bind(toId id: Id, ofDataType type: Fusable.Type, completion: @escaping (Fusable?) -> ()) -> BindingHandler {
    completion(typeStore[type.typeId]?[id])
    let handler = MockBindingHandler(server: self)
    handler.server = self
    handler.typeId = type.typeId
    handler.valueCallback = completion
    handler.observedIds = [id]
    bindingHandlers.insert(handler)
    return handler
  }
  
  public func bind(dataOfType type: Fusable.Type, matching constraints: [Constraint], completion: @escaping ([Fusable]) -> ()) -> BindingHandler {
    let handler = MockBindingHandler(server: self)
    handler.server = self
    handler.typeId = type.typeId
    handler.arrayCallback = { storables in
      let values = storables.filter { $0.matches(constraints) }
      completion(values)
    }
    bindingHandlers.insert(handler)
    return handler
  }
}

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
  
  var valueCallback: GetValueCompletion = { result in }
  var arrayCallback: ([Fusable]) -> () = { data in }

  public func remove() {
    server.bindingHandlers.remove(self)
  }
  
  fileprivate init(server: MockServer) {
    self.server = server
  }
  
  var observedIds: [Id]?
  
  func updated(value: Fusable) {
    valueCallback(.success(value))
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
  public func update(_ storable: Fusable, completion: SetCompletion) {
    set(storable, merge: false, completion: completion)
  }
  
  public func update(_ storables: [Fusable], completion: SetCompletion) {
    set(storables, merge: false, completion: completion)
  }
  
  public func update(_ storable: Fusable, on fields: [String], completion: SetCompletion) {
    update(storable, completion: completion)
  }
  
  public init(){}
  
  var typeStore = [Id: [Id: Fusable]]()
  
  var bindingHandlers = Set<MockBindingHandler>()
  
  enum BindingTypes {
    case value, array, filteredArray, typedArray
  }
    
  public func set(_ storable: Fusable, merge: Bool, completion: SetCompletion = nil) {
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
  
  public func set(_ storables: [Fusable], merge: Bool, completion: SetCompletion = nil) {
    storables.forEach {
      self.set($0, merge: merge, completion: completion)
    }
  }
  
  public func delete(_ id: Id, forDataType type: Fusable.Type, completion: SetCompletion = nil) {
    typeStore[type.typeId]?[id] = nil
  }
  
  public func get(id: Id, ofDataType type: Fusable.Type, source: DataSource = .serverOrCache, completion: @escaping GetValueCompletion) {
    let typeId = type.typeId
    let first = (typeStore[typeId]?.compactMap { return id == $0 ? $1 : nil } ?? []).first { $0.id == id }
    completion(.success(first))
  }
  
  public func get(dataType type: Fusable.Type, matching constraints: [Constraint], source: DataSource = .serverOrCache, completion: @escaping GetArrayCompletion) {
    let fusable: [Fusable] = typeStore[type.typeId]?.compactMap { return $1} ?? []
    completion(.success(fusable.filter { $0.matches(constraints) }))
  }
  
  public func bind(toId id: Id, ofDataType type: Fusable.Type, completion: @escaping GetValueCompletion) -> BindingHandler {
    completion(.success(typeStore[type.typeId]?[id]))
    let handler = MockBindingHandler(server: self)
    handler.server = self
    handler.typeId = type.typeId
    handler.valueCallback = completion
    handler.observedIds = [id]
    bindingHandlers.insert(handler)
    return handler
  }
  
  public func bind(dataType type: Fusable.Type, matching constraints: [Constraint], completion: @escaping GetArrayCompletion) -> BindingHandler {
    let handler = MockBindingHandler(server: self)
    handler.server = self
    handler.typeId = type.typeId
    handler.arrayCallback = { storables in
      let values = storables.filter { $0.matches(constraints) }
      completion(.success(values))
    }
    bindingHandlers.insert(handler)
    return handler
  }
}

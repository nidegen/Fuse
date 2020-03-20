//
//  DemoServer.swift
//  DemoServer
//
//  Created by Nicolas Degen on 20.03.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import Foundation

import Fuse

class DemoBindingHandler: BindingHandler {
  private let id = UUID().uuidString
  
  weak var server: DemoServer?
  
  var typeId: Id = ""
  
  var valueCallback: (Storable?) -> () = { data in }
  var arrayCallback: ([Storable]) -> () = { data in }
  
  func remove() {
    server?.bindingHandlers.remove(self)
  }
  
  deinit {
    remove()
  }
}

extension DemoBindingHandler: Hashable {
  static func == (lhs: DemoBindingHandler, rhs: DemoBindingHandler) -> Bool {
    lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

public class DemoServer: DataServer {
  public init(){}
  
  var typeStore = [Id: [Storable]]() {
    didSet {
      bindingHandlers.forEach { handler in
        handler.arrayCallback(typeStore[handler.typeId] ?? [])
        handler.valueCallback(typeStore[handler.typeId]?.first)
      }
    }
  }
  
  var bindingHandlers = Set<DemoBindingHandler>()
    
  public func set(_ storable: Storable) {
    if typeStore[type(of: storable).typeId] == nil {
      typeStore[type(of: storable).typeId] = [storable]
    } else {
      typeStore[type(of: storable).typeId]?.append(storable)
    }
  }
  
  public func delete(_ id: Id, forDataType type: Storable.Type, completion: ((Error?) -> ())?) {
    typeStore[type.typeId] = typeStore[type.typeId]?.filter { $0.id != id }
  }
  
  public func get(dataOfType type: Storable.Type, whereDataField dataField: String, isEqualTo value: Any, orderField: String?, descendingOrder: Bool, completion: @escaping ([Storable]) -> ()) {
    completion(typeStore[type.typeId] ?? [])
  }
  
  public func get(ids: [Id], ofDataType type: Storable.Type, completion: @escaping ([Storable]) -> ()) {
    completion(typeStore[type.typeId] ?? [])
  }
  
  public func get(id: Id, ofDataType type: Storable.Type, completion: @escaping (Storable?) -> ()) {
    let first = (typeStore[type.typeId] ?? []).first { $0.id == id }
    completion(first)
  }
  
  public func bind(typeId: Id, toId id: Id, completion: @escaping (Storable?) -> ()) -> BindingHandler {
    completion(typeStore[typeId]?.first { $0.id == id })
    let handler = DemoBindingHandler()
    handler.server = self
    handler.typeId = typeId
    handler.valueCallback = completion
    bindingHandlers.insert(handler)
    return handler
  }
  
  public func bind(typeId: Id, whereDataField dataField: String, isEqualTo value: Any, orderField: String?, descendingOrder: Bool, completion: @escaping ([Storable]) -> ()) -> BindingHandler {
    let handler = DemoBindingHandler()
    handler.server = self
    handler.typeId = typeId
    handler.arrayCallback = completion
    bindingHandlers.insert(handler)
    return handler
  }
  
  public func bind(typeId: Id, toIds ids: [Id], completion: @escaping ([Storable]) -> ()) -> BindingHandler {
    let handler = DemoBindingHandler()
    handler.server = self
    handler.typeId = typeId
    handler.arrayCallback = completion
    bindingHandlers.insert(handler)
    return handler
  }
}

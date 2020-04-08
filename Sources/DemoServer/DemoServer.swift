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
  
  var server: DemoServer
  
  var typeId: Id = ""
  
  var valueCallback: (Storable?) -> () = { data in }
  var arrayCallback: ([Storable]) -> () = { data in }
  
  func remove() {
    server.bindingHandlers.remove(self)
  }
  
  fileprivate init(server: DemoServer) {
    self.server = server
  }
  
  var observedIds: [Id]?
  
  func updated(value: Storable) {
    
    if observedIds?.contains(value.id) ?? false {
        valueCallback(value)
    } else if typeId == type(of: value).typeId {
      (server.typeStore[typeId]?.values).map {
        arrayCallback(Array($0))
      }
    }
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

public class DemoServer: Server {
  
  public init(){}
  
  var typeStore = [Id: [Id: Storable]]()
  
  var bindingHandlers = Set<DemoBindingHandler>()
  
  enum BindingTypes {
    case value, array, filteredArray, typedArray
  }
    
  public func set(_ storable: Storable) {
    if typeStore[type(of: storable).typeId] == nil {
      typeStore[type(of: storable).typeId] = [storable.id: storable]
    } else {
      typeStore[type(of: storable).typeId]?[storable.id] = storable
    }
    bindingHandlers.forEach { $0.updated(value: storable)}
  }
  
  public func delete(_ id: Id, forDataType type: Storable.Type, completion: ((Error?) -> ())?) {
    typeStore[type.typeId]?[id] = nil
  }
  
  public func get(dataOfType type: Storable.Type, whereDataField dataField: String, isEqualTo value: Any, orderField: String?, descendingOrder: Bool, completion: @escaping ([Storable]) -> ()) {
    completion(typeStore[type.typeId]?.compactMap { return $1 } ?? [])
  }
  
  public func get(ids: [Id], ofDataType type: Storable.Type, completion: @escaping ([Storable]) -> ()) {
    completion(typeStore[type.typeId]?.compactMap { return ids.contains($0) ? $1 : nil } ?? [])
  }
  
  public func get(id: Id, ofDataType type: Storable.Type, completion: @escaping (Storable?) -> ()) {
    let typeId = type.typeId
    let first = (typeStore[typeId]?.compactMap { return id == $0 ? $1 : nil } ?? []).first { $0.id == id }
    completion(first)
  }
  
  public func bind(toId id: Id, ofDataType type: Storable.Type, completion: @escaping (Storable?) -> ()) -> BindingHandler {
    completion(typeStore[type.typeId]?[id])
    let handler = DemoBindingHandler(server: self)
    handler.server = self
    handler.typeId = type.typeId
    handler.valueCallback = completion
    handler.observedIds = [id]
    bindingHandlers.insert(handler)
    return handler
  }
  
  public func bind(dataOfType type: Storable.Type, whereDataField dataField: String, isEqualTo value: Any, orderField: String?, descendingOrder: Bool, completion: @escaping ([Storable]) -> ()) -> BindingHandler {
    let handler = DemoBindingHandler(server: self)
    handler.server = self
    handler.typeId = type.typeId
    handler.arrayCallback = { storables in
      let filtered = storables.filter { storable in
        guard let json = storable.toJSONData() else { return false }
        guard let dict = ((try? JSONSerialization.jsonObject(with: json, options: .allowFragments)).flatMap { $0 as? [String: Any] }) else { return false }
        guard let fieldValue = dict[dataField] else { return false }
        
        return isEqual(a: fieldValue, b: value, as: Int.self) || isEqual(a: fieldValue, b: value, as: Double.self) || isEqual(a: fieldValue, b: value, as: Float.self) || isEqual(a: fieldValue, b: value, as: String.self) || isEqual(a: fieldValue, b: value, as: Bool.self)
      }
      let sorted = filtered
      completion(sorted)
    }
    bindingHandlers.insert(handler)
    return handler
  }
  
  
  public func bind(dataOfType type: Storable.Type, whereDataField dataField: String, contains value: Any, completion: @escaping ([Storable]) -> ()) -> BindingHandler {
    let handler = DemoBindingHandler(server: self)
    handler.server = self
    handler.typeId = type.typeId
    handler.arrayCallback = { storables in
      let filtered = storables.filter { storable in
        guard let json = storable.toJSONData() else { return false }
        guard let dict = ((try? JSONSerialization.jsonObject(with: json, options: .allowFragments)).flatMap { $0 as? [String: Any] }) else { return false }
        guard let fieldValue = dict[dataField] else { return false }
        
        return isEqual(a: fieldValue, b: value, as: Int.self) || isEqual(a: fieldValue, b: value, as: Double.self) || isEqual(a: fieldValue, b: value, as: Float.self) || isEqual(a: fieldValue, b: value, as: String.self) || isEqual(a: fieldValue, b: value, as: Bool.self)
      }
      let sorted = filtered
      completion(sorted)
    }
    bindingHandlers.insert(handler)
    return handler
  }
  
  public func bind(toIds ids: [Id], ofDataType type: Storable.Type,  completion: @escaping ([Storable]) -> ()) -> BindingHandler {
    let handler = DemoBindingHandler(server: self)
    handler.server = self
    handler.typeId = type.typeId
    handler.arrayCallback = completion
    handler.observedIds = ids
    bindingHandlers.insert(handler)
    return handler
  }
  
  public func bind(toDataType type: Storable.Type, completion: @escaping ([Storable]) -> ()) -> BindingHandler {
    let handler = DemoBindingHandler(server: self)
    handler.server = self
    handler.typeId = type.typeId
    handler.arrayCallback = completion
    bindingHandlers.insert(handler)
    return handler
  }
}

func isEqual<T: Equatable>(a: Any, b: Any, as type: T.Type) -> Bool {
  guard let aa = a as? T else { return false }
  guard let bb = b as? T else { return false }
  return aa == bb
}

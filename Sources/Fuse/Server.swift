//
//  Server.swift
//  Fuse
//
//  Created by Nicolas Degen on 19.03.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import Foundation

public protocol BindingHandler: class {
  func remove()
}

public struct DefaultServerContainer {
  static var _server: Server?
  public static var server: Server {
    get {
      return _server!
    }
    
    set {
      _server = newValue
    }
  }
}

public protocol Server: class {
  func set(_ storables: [Fusable])
  func set(_ storable: Fusable)
  func delete(_ id: Id, forDataType type: Fusable.Type, completion: ((Error?)->())?)
  
  func get(dataOfType type: Fusable.Type, whereDataField dataField: String, isEqualTo value: Any, orderField: String?,
           descendingOrder: Bool, completion: @escaping ([Fusable])->())
  func get(ids: [Id], ofDataType type: Fusable.Type, completion: @escaping ([Fusable])->())
  func get(id: Id, ofDataType type: Fusable.Type, completion: @escaping (Fusable?)->())
  
  func bind(toId id: Id, ofDataType type: Fusable.Type, completion: @escaping (Fusable?) -> ()) -> BindingHandler
  
  func bind(toIds ids: [Id], dataOfType type: Fusable.Type, completion: @escaping ([Fusable]) -> ()) -> BindingHandler
  
  func bind(dataOfType type: Fusable.Type, whereDataField dataField: String, isEqualTo value: Any, orderField: String?, descendingOrder: Bool, completion: @escaping ([Fusable]) -> ()) -> BindingHandler
  
  func bind(dataOfType type: Fusable.Type, whereDataField dataField: String, isContainedIn value: [Any], orderField: String?, descendingOrder: Bool, completion: @escaping ([Fusable]) -> ()) -> BindingHandler
  
  func bind(dataOfType type: Fusable.Type, whereDataField dataField: String, contains value: Any, completion: @escaping ([Fusable]) -> ()) -> BindingHandler
  
  func bind(toDataType type: Fusable.Type, completion: @escaping ([Fusable]) -> ()) -> BindingHandler
}

public extension Server {
  
  func set(_ storables: [Fusable]) {
    storables.forEach { set($0) }
  }
  
  func bind<T: Fusable>(whereDataField dataField: String, isContainedIn values: [Any], orderField: String? = nil,
                         descendingOrder: Bool = true, completion: @escaping ([T])->()) -> BindingHandler {
    self.bind(dataOfType: T.self, whereDataField: dataField, isContainedIn: values, orderField: orderField,
                descendingOrder: descendingOrder) { data in
                  completion(data as? [T] ?? [])
    }
  }
  
  func bind<T: Fusable>(whereDataField dataField: String, isEqualTo value: Any, orderField: String? = nil,
                         descendingOrder: Bool = true, completion: @escaping ([T])->()) -> BindingHandler {
    self.bind(dataOfType: T.self, whereDataField: dataField, isEqualTo: value, orderField: orderField,
                descendingOrder: descendingOrder) { data in
                  completion(data as? [T] ?? [])
    }
  }
  
  func bind<T: Fusable>(whereDataField dataField: String, contains value: Any, completion: @escaping ([T])->()) -> BindingHandler {
    self.bind(dataOfType: T.self, whereDataField: dataField, contains: value) { data in
                  completion(data as? [T] ?? [])
    }
  }
  
  func bind<T: Fusable>(completion: @escaping ([T])->()) -> BindingHandler {
    return self.bind(toDataType: T.self) { data in
      completion(data as? [T] ?? [])
    }
  }
  
  func bind<T: Fusable>(toId id: Id, completion: @escaping (T?)->()) -> BindingHandler {
    return self.bind(toId: id, ofDataType: T.self) { data in
      completion(data as? T)
    }
  }
  
  func bind<T: Fusable>(toIds ids: [Id], completion: @escaping ([T])->()) -> BindingHandler {
    return self.bind(toIds: ids, dataOfType : T.self) { data in
      completion(data as? [T] ?? [])
    }
  }
  
  func get<T: Fusable>(whereDataField dataField: String, isEqualTo value: Any, orderField: String? = nil,
                        descendingOrder: Bool = true, completion: @escaping ([T])->()) {
    get(dataOfType: T.self, whereDataField: dataField, isEqualTo: value, orderField: orderField, descendingOrder: descendingOrder) { data in
      completion((data as? [T]) ?? [])
    }
  }
  
  func get<T: Fusable>(ids: [Id], completion: @escaping ([T])->()) {
    get(ids: ids, ofDataType: T.self) { data in
      completion((data as? [T]) ?? [])
    }
  }
  
  func get<T: Fusable>(id: Id, completion: @escaping (T?)->()) {
    get(id: id, ofDataType: T.self) { data in
      completion((data as? T?) ?? nil)
    }
  }
}

//protocol Server {
//
//  func delete<Storable: Storable>(_ id: Id, forDataType type: Storable.Type,
//  completion: ((Error?)->())? = nil)
//
//  func set<Storable: Storable>(_ storables: [Storable])
//
//  func set<Storable: Storable>(_ storable: Storable)
//
//  func get<Storable: Storable>(whereDataField dataField: String, isEqualTo value: Any,
//  orderField: String? = nil,
//  descending: Bool = false,
//  completion: @escaping ([Storable])->())
//
//  func get<Storable: Storable>(forIds ids: [Id], completion: @escaping ([Storable])->())
//
//  func get<Storable: Storable>(forId id: Id, completion: @escaping (Storable?)->())

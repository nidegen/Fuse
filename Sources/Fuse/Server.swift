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

public protocol Server: class {
  func set(_ storables: [Storable])
  func set(_ storable: Storable)
  func delete(_ id: Id, forDataType type: Storable.Type, completion: ((Error?)->())?)
  
  func get(dataOfType type: Storable.Type, whereDataField dataField: String, isEqualTo value: Any, orderField: String?,
           descendingOrder: Bool, completion: @escaping ([Storable])->())
  func get(ids: [Id], ofDataType type: Storable.Type, completion: @escaping ([Storable])->())
  func get(id: Id, ofDataType type: Storable.Type, completion: @escaping (Storable?)->())
  
  func bind(toId id: Id, ofDataType type: Storable.Type, completion: @escaping (Storable?) -> ()) -> BindingHandler
  
  func bind(dataOfType type: Storable.Type, whereDataField dataField: String, isEqualTo value: Any, orderField: String?, descendingOrder: Bool, completion: @escaping ([Storable]) -> ()) -> BindingHandler
  
  func bind(dataOfType type: Storable.Type, whereDataField dataField: String, contains value: Any, completion: @escaping ([Storable]) -> ()) -> BindingHandler
  
  func bind(toDataType type: Storable.Type, completion: @escaping ([Storable]) -> ()) -> BindingHandler
}

public extension Server {
  
  func set(_ storables: [Storable]) {
    storables.forEach { set($0) }
  }
  
  func bind<T: Storable>(whereDataField dataField: String, isEqualTo value: Any, orderField: String? = nil,
                         descendingOrder: Bool = true, completion: @escaping ([T])->()) -> BindingHandler {
    self.bind(dataOfType: T.self, whereDataField: dataField, isEqualTo: value, orderField: orderField,
                descendingOrder: descendingOrder) { data in
                  completion(data as? [T] ?? [])
    }
  }
  
  func bind<T: Storable>(whereDataField dataField: String, contains value: Any, completion: @escaping ([T])->()) -> BindingHandler {
    self.bind(dataOfType: T.self, whereDataField: dataField, contains: value) { data in
                  completion(data as? [T] ?? [])
    }
  }
  
  func bind<T: Storable>(completion: @escaping ([T])->()) -> BindingHandler {
    return self.bind(toDataType: T.self) { data in
      completion(data as? [T] ?? [])
    }
  }
  
  func bind<T: Storable>(toId id: Id, completion: @escaping (T?)->()) -> BindingHandler {
    return self.bind(toId: id, ofDataType: T.self) { data in
      completion(data as? T)
    }
  }
  
  
  func get<T: Storable>(whereDataField dataField: String, isEqualTo value: Any, orderField: String? = nil,
                        descendingOrder: Bool = true, completion: @escaping ([T])->()) {
    get(dataOfType: T.self, whereDataField: dataField, isEqualTo: value, orderField: orderField, descendingOrder: descendingOrder) { data in
      completion((data as? [T]) ?? [])
    }
  }
  
  func get<T: Storable>(ids: [Id], completion: @escaping ([T])->()) {
    get(ids: ids, ofDataType: T.self) { data in
      completion((data as? [T]) ?? [])
    }
  }
  
  func get<T: Storable>(id: Id, completion: @escaping (T?)->()) {
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

//
//  FuseServer.swift
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
  static var _server: FuseServer?
  public static var server: FuseServer {
    get {
      return _server!
    }
    
    set {
      _server = newValue
    }
  }
}

public typealias SetterCompletion = ((Error?)->())?

public protocol FuseServer: class {
  func set(_ storables: [Fusable], completion: SetterCompletion)
  func set(_ storable: Fusable, completion: SetterCompletion)
  func delete(_ id: Id, forDataType type: Fusable.Type, completion: SetterCompletion)
  
  func get(dataOfType type: Fusable.Type, matching constraints: [Constraint], completion: @escaping ([Fusable])->())
  func get(id: Id, ofDataType type: Fusable.Type, completion: @escaping (Fusable?)->())
  
  func bind(toId id: Id, ofDataType type: Fusable.Type, completion: @escaping (Fusable?) -> ()) -> BindingHandler
  func bind(dataOfType type: Fusable.Type, matching constraints: [Constraint], completion: @escaping ([Fusable]) -> ()) -> BindingHandler
}

public extension FuseServer {
  
  func set(_ storables: [Fusable]) {
    storables.forEach { set($0, completion: nil) }
  }
  
  func bind<T: Fusable>(matching constraints: [Constraint] = [], completion: @escaping ([T])->()) -> BindingHandler {
    self.bind(dataOfType: T.self, matching: constraints) { data in
                  completion(data as? [T] ?? [])
    }
  }
  
  func bind<T: Fusable>(toId id: Id, completion: @escaping (T?)->()) -> BindingHandler {
    return self.bind(toId: id, ofDataType: T.self) { data in
      completion(data as? T)
    }
  }
  
  func get<T: Fusable>(matching constraints: [Constraint] = [], completion: @escaping ([T])->()) {
    get(dataOfType: T.self, matching: constraints) { data in
      completion((data as? [T]) ?? [])
    }
  }
  
  func get<T: Fusable>(id: Id, completion: @escaping (T?)->()) {
    get(id: id, ofDataType: T.self) { data in
      completion((data as? T?) ?? nil)
    }
  }
  
  func get<T: Fusable>(id: Id) -> T? {
    var returnValue: T?
    let dispatchGroup  = DispatchGroup()

    dispatchGroup.enter()
    get(id: id, ofDataType: T.self) { data in
      dispatchGroup.leave()
      returnValue = data as? T ?? nil
    }

    dispatchGroup.wait(timeout: .init(uptimeNanoseconds: 1000 * 1000 * 1000))
    return returnValue
  }
  
  func set<T: Fusable>(_ data: T, completion: SetterCompletion = { _ in }) {
    set(data as Fusable, completion: completion)
  }
  
  func update<T: Fusable>(_ data: T, update: @escaping (T?)->(T)) {
    get(id: data.id) { (data:T?) in
      self.set(update(data))
    }
  }
  func update<T: Fusable>(_ id: Id, update: @escaping (T?)->(T)) {
    get(id: id) { (data:T?) in
      self.set(update(data))
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

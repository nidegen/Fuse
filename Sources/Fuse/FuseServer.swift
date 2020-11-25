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

public typealias FuseCompletion = ((Error?)->())?
@available(*, deprecated, renamed: "FuseCompletion")
public typealias SetterCompletion = ((Error?)->())?

public protocol FuseServer: class {
  func set(_ storables: [Fusable], merge: Bool, completion: FuseCompletion)
  func set(_ storable: Fusable, merge: Bool, completion: FuseCompletion)
  func update(_ storables: [Fusable], completion: FuseCompletion)
  func update(_ storable: Fusable, completion: FuseCompletion)
  func delete(_ id: Id, forDataType type: Fusable.Type, completion: FuseCompletion)
  
  func get(dataOfType type: Fusable.Type, matching constraints: [Constraint], completion: @escaping ([Fusable])->())
  func get(id: Id, ofDataType type: Fusable.Type, completion: @escaping (Fusable?)->())
  
  func bind(toId id: Id, ofDataType type: Fusable.Type, completion: @escaping (Fusable?) -> ()) -> BindingHandler
  func bind(dataOfType type: Fusable.Type, matching constraints: [Constraint], completion: @escaping ([Fusable]) -> ()) -> BindingHandler
}

public extension FuseServer {
  
  func set<T: Fusable>(_ data: T, merge: Bool = false,  completion: FuseCompletion = nil) {
    set(data as Fusable, merge: merge, completion: completion)
  }
  
  func set<T: Fusable>(_ data: [T], merge: Bool = false, completion: FuseCompletion = nil) {
    set(data as [Fusable], merge: merge, completion: completion)
  }
  
  func update<T: Fusable>(_ data: T, completion: FuseCompletion = nil) {
    self.update(data as Fusable, completion: completion)
  }
  
  func update<T: Fusable>(_ data: [T], completion: FuseCompletion = nil) {
    self.update(data as [Fusable], completion: completion)
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
  
  @available(*, deprecated, renamed: "FuseCompletion")
  func get<T: Fusable>(id: Id) -> T? {
    getSync(id: id)
  }
  
  func getSync<T: Fusable>(id: Id) -> T? {
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
  
  
  func update<T: Fusable>(_ data: T, update: @escaping (T?)->(T)) {
    get(id: data.id) { (data:T?) in
      self.update(update(data), completion: nil)
    }
  }
  
  func update<T: Fusable>(_ id: Id, update: @escaping (T?)->(T)) {
    get(id: id) { (data:T?) in
      self.update(update(data), completion: nil)
    }
  }
}

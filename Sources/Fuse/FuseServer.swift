import Foundation

public protocol BindingHandler: class {
  func remove()
}

public typealias SetCompletion = ((Error?)->())?

public typealias GetValueCompletion = ((Result<Fusable?, Error>)->())
public typealias GetArrayCompletion = ((Result<[Fusable], Error>)->())

public typealias ValueResult<T: Fusable> = Result<T?, Error>
public typealias ArrayResult<T: Fusable> = Result<Array<T>, Error>
public typealias ValueCompletion<T: Fusable> = (ValueResult<T>) -> ()
public typealias ArrayCompletion<T: Fusable> = (ArrayResult<T>) -> ()

public enum DataSource { case serverOnly, serverOrCache, cacheOnly }

public protocol FuseServer: class {
  func set(_ storables: [Fusable], merge: Bool, completion: SetCompletion)
  func set(_ storable: Fusable, merge: Bool, completion: SetCompletion)
  func update(_ storables: [Fusable], completion: SetCompletion)
  func update(_ storable: Fusable, on fields: [String], completion: SetCompletion)
  func update(_ storable: Fusable, completion: SetCompletion)
  func delete(_ id: Id, forDataType type: Fusable.Type, completion: SetCompletion)
  
  func get(dataType type: Fusable.Type, matching constraints: [Constraint], source: DataSource, completion: @escaping GetArrayCompletion)
  func get(id: Id, ofDataType type: Fusable.Type, source: DataSource, completion: @escaping GetValueCompletion)
  
  func bind(toId id: Id, ofDataType type: Fusable.Type, completion: @escaping GetValueCompletion) -> BindingHandler
  func bind(dataType type: Fusable.Type, matching constraints: [Constraint], completion: @escaping GetArrayCompletion) -> BindingHandler
}

public extension FuseServer {
  
  func set<T: Fusable>(_ data: T, merge: Bool = false,  completion: SetCompletion = nil) {
    set(data as Fusable, merge: merge, completion: completion)
  }
  
  func set<T: Fusable>(_ data: [T], merge: Bool = false, completion: SetCompletion = nil) {
    set(data as [Fusable], merge: merge, completion: completion)
  }
  
  func update<T: Fusable>(_ data: T, completion: SetCompletion = nil) {
    self.update(data as Fusable, completion: completion)
  }
  
  func update<T: Fusable>(_ data: [T], completion: SetCompletion = nil) {
    self.update(data as [Fusable], completion: completion)
  }
  
  func update<T: Fusable>(_ data: T, on fields: [String], completion: SetCompletion) {
    self.update(data as Fusable, on: fields, completion: completion)
  }

  
  func bind<T: Fusable>(matching constraints: [Constraint] = [],
                        completion: @escaping ArrayCompletion<T>) -> BindingHandler {
    self.bind(dataType: T.self, matching: constraints) { result in
      switch result {
      case .success(let data):
        completion(.success(data as? [T] ?? []))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  
  func bind<T: Fusable>(toId id: Id,
                        completion: @escaping ValueCompletion<T>) -> BindingHandler {
    return self.bind(toId: id, ofDataType: T.self) { result in
      switch result {
      case .success(let data):
        completion(.success(data as? T? ?? nil))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  
  func get<T: Fusable>(matching constraints: [Constraint] = [],
                       source: DataSource = .serverOrCache,
                       completion: @escaping ArrayCompletion<T>) {
    get(dataType: T.self, matching: constraints, source: source) { result in
      switch result {
      case .success(let data):
        completion(.success(data as? [T] ?? []))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  
  func get<T: Fusable>(id: Id, source: DataSource = .serverOrCache,
                       completion: @escaping ValueCompletion<T>) {
    get(id: id, ofDataType: T.self, source: source) { result in
      switch result {
      case .success(let data):
        completion(.success(data as? T? ?? nil))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  
  func delete(_ id: Id, forDataType type: Fusable.Type) {
    delete(id, forDataType: type, completion: nil)
  }
  
  func getSync<T: Fusable>(id: Id, source: DataSource = .serverOrCache) -> T? {
    var returnValue: T?
    let dispatchGroup  = DispatchGroup()

    dispatchGroup.enter()
    get(id: id, ofDataType: T.self, source: source) { result in
      dispatchGroup.leave()
      switch result {
      case .success(let data):
        returnValue = data as? T ?? nil
      case .failure(let error):
        print(error.localizedDescription)
        returnValue = nil
      }
    }

    let _ = dispatchGroup.wait(timeout: .init(uptimeNanoseconds: 1000 * 1000 * 1000))
    return returnValue
  }
}

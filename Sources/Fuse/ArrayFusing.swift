import Combine

@propertyWrapper
public class ArrayFusing<T:Fusable> {
  var data: [T]
  var observerHandle: BindingHandler!
  var server: FuseServer
  
  public var didUpdate: (([T])->())?
  
  public init(server: FuseServer, ids: [Id], publisher: ObservableObjectPublisher? = nil) {
    self.data = [T]()
    self.server = server
    if !ids.isEmpty {
      observerHandle = self.server.bind(matching: [Constraint(ids: ids)]) { [weak self] (update: [T]) in
        self?.callback(update: update)
      }
    }
    objectWillChange = publisher
  }

  public init(server: FuseServer, matching constraints: [Constraint] = [], publisher: ObservableObjectPublisher? = nil) {
    self.data = [T]()
    self.server = server
    observerHandle = self.server.bind(matching: constraints) { [weak self] (update: [T]) in
      self?.callback(update: update)
    }
    objectWillChange = publisher
  }

  public init(_ option: FusingOption, server: FuseServer) {
    self.server = server
    self.data = []
  }
  
  func callback(update: [T]) {
    self.objectWillChange?.send()
    self.data = update
    didUpdate?(update)
  }
  
  public var wrappedValue: [T] {
    get {
      return data
    }
    
    set {
      objectWillChange?.send()
      data = newValue
      server.update(data)
    }
  }

  public var objectWillChange: ObservableObjectPublisher?
}

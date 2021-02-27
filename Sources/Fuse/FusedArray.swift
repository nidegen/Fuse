import Combine

@available(*, deprecated, renamed: "Fused")
typealias ArrayFusing = FusedArray

@propertyWrapper
public class FusedArray<T:Fusable> {
  var data: [T]
  var observerHandle: BindingHandler!
  var server: FuseServer
  var constraints: [Constraint]
  
  public var didUpdate: (([T])->())?
  
  public var updateFilter: (([T])->([T])) = { return $0 }
  
  public init(server: FuseServer, matching constraints: [Constraint] = [], publisher: ObservableObjectPublisher? = nil) {
    self.data = [T]()
    self.server = server
    self.constraints = constraints
    observerHandle = listen()
    objectWillChange = publisher
  }
  
  public convenience init(server: FuseServer, ids: [Id], publisher: ObservableObjectPublisher? = nil) {
    self.init(server: server, matching: [Constraint(ids: ids)], publisher: publisher)
  }
  
  func listen() -> BindingHandler {
    return self.server.bind(matching: constraints) { [weak self] (result: ArrayResult<T>) in
      switch result {
      case .success(let update):
        self?.callback(update: update)
      case .failure(let error):
        print(error.localizedDescription)
      }
    }
  }
  
  public func pause() {
    self.observerHandle.remove()
  }
  
  public func start() {
    self.observerHandle = listen()
  }
  
  func callback(update: [T]) {
    self.objectWillChange?.send()
    publisher?.subject.value = update
    self.data = updateFilter(update)
    didUpdate?(update)
  }
  
  public var wrappedValue: [T] {
    get {
      return data
    }
    
    set {
      objectWillChange?.send()
      publisher?.subject.value = newValue
      self.data = updateFilter(newValue)
      server.update(data)
    }
  }

  // ObservableObject Publisher
  public var objectWillChange: ObservableObjectPublisher?
  
  
  // Custom Publisher
  private var publisher: Publisher?
    
  public var projectedValue: Publisher {
    get {
      if let publisher = publisher {
        return publisher
      }
      let publisher = Publisher(wrappedValue)
      self.publisher = publisher
      return publisher
    }
  }
  
  
  public struct Publisher: Combine.Publisher {
    
    public typealias Output = [T]
    
    public typealias Failure = Never
    
    public func receive<Downstream: Subscriber>(subscriber: Downstream)
    where Downstream.Input == [T], Downstream.Failure == Never {
      subject.subscribe(subscriber)
    }
    
    fileprivate let subject: Combine.CurrentValueSubject<[T], Never>
    
    fileprivate init(_ output: Output) {
      subject = .init(output)
    }
  }
}

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
    publisher?.subject.value = update
    self.data = update
    didUpdate?(update)
  }
  
  public var wrappedValue: [T] {
    get {
      return data
    }
    
    set {
      objectWillChange?.send()
      publisher?.subject.value = newValue
      data = newValue
      server.update(data)
    }
  }

  public var objectWillChange: ObservableObjectPublisher?
  
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

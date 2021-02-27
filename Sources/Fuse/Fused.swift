import Combine

@available(*, deprecated, renamed: "Fused")
typealias Fusing = Fused

@propertyWrapper
public class Fused<T:Fusable> {
  var data: T
  var observerHandle: BindingHandler!
  var server: FuseServer
  
  public var didUpdate: ((T)->())?
    
  public init(wrappedValue value: T, server: FuseServer,
              publisher: ObservableObjectPublisher? = nil,
              settingNew: Bool = false) {
    self.data = value
    self.server = server
    if settingNew {
      self.server.set(value, completion: nil)
    }
    self.observerHandle = listen()
      
    self.objectWillChange = publisher
  }
  
  func listen() -> BindingHandler {
    return self.server.bind(toId: data.id) { [weak self] (result: ValueResult<T>) in
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
  
  func callback(update: T?) {
    update.map {
      self.objectWillChange?.send()
      self.publisher?.subject.value = $0
      self.data = $0
      self.didUpdate?($0)
    }
  }
  
  public var wrappedValue: T {
    get {
      return data
    }
    
    set {
      objectWillChange?.send()
      let old = data
      data = newValue
      server.update(data) { (error: Error?) in
        if error == nil {
          self.didUpdate?(newValue)
        } else {
          self.data = old
        }
      }
      publisher?.subject.value = newValue
    }
  }
  
  // Custom Publisher
  
  public struct Publisher: Combine.Publisher {
    
    public typealias Output = T
    
    public typealias Failure = Never
    
    public func receive<Downstream: Subscriber>(subscriber: Downstream)
      where Downstream.Input == T, Downstream.Failure == Never {
        subject.subscribe(subscriber)
    }
    
    fileprivate let subject: Combine.CurrentValueSubject<T, Never>
    
    fileprivate init(_ output: Output) {
      subject = .init(output)
    }
  }
  
  private var publisher: Publisher?
  
  public var objectWillChange: ObservableObjectPublisher?
  
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

//  // Observable Publisher
//
//  public static subscript<EnclosingSelf: ObservableObject>(
//    _enclosingInstance object: EnclosingSelf,
//    wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, T>,
//    storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Fused<T>>
//  ) -> T {
//    get {
//      if object[keyPath: storageKeyPath].objectWillChange == nil {
//        object[keyPath: storageKeyPath].objectWillChange = object.objectWillChange as? ObservableObjectPublisher
//      }
//      return object[keyPath: storageKeyPath].wrappedValue
//    }
//    set {
//      if object[keyPath: storageKeyPath].objectWillChange == nil {
//        object[keyPath: storageKeyPath].objectWillChange = object.objectWillChange as? ObservableObjectPublisher
//      }
//      object[keyPath: storageKeyPath].objectWillChange?.send()
//      object[keyPath: storageKeyPath].publisher?.subject.send(newValue)
//      object[keyPath: storageKeyPath].wrappedValue = newValue
//    }
//  }
}

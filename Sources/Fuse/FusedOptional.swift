import Combine

@available(*, deprecated, renamed: "Fused")
typealias OptionalFusing = FusedOptional

@propertyWrapper
public class FusedOptional<T:Fusable> {
  var data: T?
  var observerHandle: BindingHandler!
  var server: FuseServer
  var id: Id?
  var settingNew: Bool
  
  public var didUpdate: ((T?)->())?
  
  public init(id: Id?, server: FuseServer, settingNew: Bool = false) {
    self.id = id
    self.server = server
    self.settingNew = settingNew
        
    self.observerHandle = listen()
  }
  
  public init(_ data: T, server: FuseServer, settingNew: Bool = false) {
    self.server = server
    self.settingNew = settingNew
    bindToData(data: data)
  }
  
  
  func listen() -> BindingHandler? {
    guard let id = id else { return nil }
    
    return self.server.bind(toId: id) { [weak self] (result: ValueResult<T>) in
      switch result {
      case .success(let update):
        self?.callback(update: update)
      case .failure(let error):
        print(error.localizedDescription)
      }
    }
  }
  
  public func pause() {
    if self.observerHandle.isActive {
      self.observerHandle.remove()
    }
  }
  
  public func start() {
    if !self.observerHandle.isActive {
      self.observerHandle = listen()
    }
  }
  
  func callback(update: T?) {
    self.objectWillChange?.send()
    self.publisher?.subject.value = update
    self.data = update
    self.didUpdate?(update)
  }
  
  func bindToData(data: T) {
    self.id = data.id
    self.data = data
    self.didUpdate?(data)
    if settingNew {
      self.server.set(data, completion: nil)
    }
    
    self.observerHandle = listen()
  }
  
  public var wrappedValue: T? {
    get {
      return data
    }
    
    set {
      let old = data
      data = newValue
      
      if let newData = newValue {
        if id == nil || id == newData.id {
          if observerHandle == nil {
            bindToData(data: newData)
          } else {
            server.update(newData) { (error: Error?) in
              if error == nil {
                self.objectWillChange?.send()
                self.publisher?.subject.value = newValue
                self.didUpdate?(newValue)
              } else {
                self.data = old
              }
            }
            self.data = newData
          }
        } else {
          print("Error: Data with non-matching Id assigned to Optional Fusing. Ignoring")
          return
        }
      } else {
        data = nil
        observerHandle = nil
        if let id = self.id {
          server.delete(id, forDataType: T.self) { error in
            if let error = error {
              self.data = old
              print(error.localizedDescription)
            }
          }
        }
        self.id = nil
      }
    }
  }
  
  public struct Publisher: Combine.Publisher {
    
    public typealias Output = T?
    
    public typealias Failure = Never
    
    public func receive<Downstream: Subscriber>(subscriber: Downstream)
      where Downstream.Input == T?, Downstream.Failure == Never {
        subject.subscribe(subscriber)
    }
    
    fileprivate let subject: Combine.CurrentValueSubject<T?, Never>
    
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
}

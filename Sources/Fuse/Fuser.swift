import Foundation

@propertyWrapper
public class Fuser<T:Fusable>: ObservableObject {
  var data: Fusing<T>
    
  public init(wrappedValue: T, server: FuseServer,  updatingServer: Bool = true) {
    let server = server
    data = Fusing(wrappedValue: wrappedValue, server: server, updatingServer: updatingServer)
    data.objectWillChange = self.objectWillChange
  }
  
  public var wrappedValue: T {
    get {
      return data.wrappedValue
    }
    
    set {
      data.wrappedValue = newValue
    }
  }
}

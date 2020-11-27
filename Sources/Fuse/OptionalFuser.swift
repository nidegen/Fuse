import Foundation

@propertyWrapper
public class OptionalFuser<T:Fusable>: ObservableObject {
  var data: OptionalFusing<T>
    
  public init(id: Id, server: FuseServer) {
    let server = server
    data = OptionalFusing(id: id, server: server)
    data.objectWillChange = self.objectWillChange
  }
  
  
  public var wrappedValue: T? {
    get {
      return data.wrappedValue
    }
    
    set {
      data.wrappedValue = newValue
    }
  }
}

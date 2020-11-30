import Foundation

@propertyWrapper
public class Fuser<T:Fusable>: ObservableObject {
  var data: Fusing<T>
    
  public init(wrappedValue: T, server: FuseServer,  settingNew: Bool = false) {
    let server = server
    data = Fusing(wrappedValue: wrappedValue, server: server, settingNew: settingNew)
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

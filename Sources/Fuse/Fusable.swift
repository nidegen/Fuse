import Foundation

public typealias Id = String

typealias Storable = Fusable

public protocol Fusable: Codable {
  static var typeId: Id { get }
  static var serverVersionString: String { get }
  var id: Id { get }
}

var encoder: JSONEncoder = {
  let encoder = JSONEncoder()
  encoder.dateEncodingStrategy = .iso8601
  return encoder
}()

var decoder: JSONDecoder = {
  let decoder = JSONDecoder()
  decoder.dateDecodingStrategy = .iso8601
  return decoder
}()

// Note: to access the variable's actual type, use type(of: storable).typeId
public extension Fusable {
  
  static var serverVersionString: String { "undefined" }
  
  static var typeId: String {
    return "\(self)".deletingSuffix("Data").camelCaseToSnakeCase()
  }
  
  static func decode(fromData data: Data) throws -> Fusable {
    return try decoder.decode(self, from: data)
  }
  
  func toJSONData() -> Data? { try? encoder.encode(self) }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  static func ==(lhs: Fusable, rhs: Fusable) -> Bool {
    return lhs.id == rhs.id
  }
  
  func parseDictionary() -> [String: Any]? {
    guard let data = self.toJSONData() else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}

extension String {
  func deletingSuffix(_ suffix: String) -> String {
    guard self.hasSuffix(suffix) else { return self }
    return String(self.dropLast(suffix.count))
  }
  
  public func camelCaseToSnakeCase() -> String {
    let acronymPattern = "([A-Z]+)([A-Z][a-z]|[0-9])"
    let normalPattern = "([a-z0-9])([A-Z])"
    return self.processCamalCaseRegex(pattern: acronymPattern)?
      .processCamalCaseRegex(pattern: normalPattern)?.lowercased() ?? self.lowercased()
  }
  
  fileprivate func processCamalCaseRegex(pattern: String) -> String? {
    let regex = try? NSRegularExpression(pattern: pattern, options: [])
    let range = NSRange(location: 0, length: count)
    return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2")
  }
}

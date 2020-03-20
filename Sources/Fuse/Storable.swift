//
//  Storable.swift
//  Fuse
//
//  Created by Nicolas Degen on 19.03.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import Foundation

public typealias Id = String

public protocol Storable: Codable {
  static var typeId: Id { get }
  var id: Id { get }
}

// Note: to access the variable's actual type, use type(of: storable).typeId
public extension Storable {
  static var typeId: String {
    return "\(self)".deletingSuffix("Data").camelCaseToSnakeCase()
  }
}

public func getTypeId<T: Storable>(_ storable: T) -> Id {
  return "\(type(of: storable))".deletingSuffix("Data").camelCaseToSnakeCase()
}

extension String {
  func deletingSuffix(_ suffix: String) -> String {
    guard self.hasSuffix(suffix) else { return self }
    return String(self.dropLast(suffix.count))
  }
  
  func camelCaseToSnakeCase() -> String {
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

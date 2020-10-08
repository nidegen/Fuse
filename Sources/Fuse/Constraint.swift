//
//  Constraint.swift
//  Fuse
//
//  Created by Nicolas Degen on 08.09.20.
//  Copyright © 2020 Nicolas Degen. All rights reserved.
//

import Foundation

public enum Relation {
  case isContaining(value: Any)
  case isEqual(value: Any)
  case isContainedIn(value: [Any])
  case isExisting
  case isNotExisting
  case isGreaterThan(value: Any)
  case isLessThan(value: Any)
  case ordered(ascending: Bool)
}

public struct Constraint {
  public var field: String
  public var relation: Relation
  
  public init(whereDataField field: String, _ relation: Relation) {
    self.field = field
    self.relation = relation
  }
  
  public init(ids: [Id]) {
    self.field = "id"
    self.relation = .isContainedIn(value: ids)
  }
}

public extension Array where Element: Fusable {
  func matching(_ constraints: [Constraint]) -> Self {
    self.filter { $0.matches(constraints) }
  }
}

public extension Fusable {
  func matches(_ constraint: Constraint) -> Bool {
    switch constraint.relation {
    case .isContaining(let value):
      guard let fieldValue = self.parseDictionary()?[constraint.field] else { return false }
      guard let value = value as? String else { return false }
      return (fieldValue as? [String])?.contains(value) ?? false
    case .isContainedIn(let valueArray):
      for value in valueArray {
        guard let fieldValue = self.parseDictionary()?[constraint.field] else { continue }
        if fieldValue as? String == value as? String { return true }
      }
      return false
    case .isEqual(let value):
      guard let fieldValue = self.parseDictionary()?[constraint.field] else { return false }
      print(fieldValue)
      print(value)
      
      return isEqual(a: fieldValue, b: value, as: Bool.self)
          || isEqual(a: fieldValue, b: value, as: Float.self)
          || isEqual(a: fieldValue, b: value, as: Int.self)
          || isEqual(a: fieldValue, b: value, as: String.self)
      
    default:
      return false
    }
  }
  
  func matches(_ constraints: [Constraint]) -> Bool {
    !(constraints.compactMap { self.matches($0) }).contains(false)
  }
}

public func isEqual<T: Equatable>(a: Any, b: Any, as type: T.Type) -> Bool {
  guard let aa = a as? T else { return false }
  guard let bb = b as? T else { return false }
  return aa == bb
}

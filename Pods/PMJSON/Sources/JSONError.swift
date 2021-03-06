//
//  JSONError.swift
//  PMJSON
//
//  Created by Kevin Ballard on 11/9/15.
//  Copyright © 2016 Postmates.
//
//  Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
//  http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
//  <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
//  option. This file may not be copied, modified, or distributed
//  except according to those terms.
//

// MARK: JSONError

/// Errors thrown by the JSON `get*` or `to*` accessor families.
public enum JSONError: ErrorType, CustomStringConvertible {
    /// Thrown when a given path is missing or has the wrong type.
    /// - Parameter path: The path of the key that caused the error.
    /// - Parameter expected: The type that was expected at this path.
    /// - Parameter actual: The type of the value found at the path, or `nil` if there was no value.
    case MissingOrInvalidType(path: String?, expected: ExpectedType, actual: JSONType?)
    /// Thrown when an integral value is coerced to a smaller type (e.g. `Int64` to `Int`) and the
    /// value doesn't fit in the smaller type.
    /// - Parameter path: The path of the value that cuased the error.
    /// - Parameter value: The actual value at that path.
    /// - Parameter expected: The type that the value doesn't fit in, e.g. `Int.self`.
    case OutOfRangeInt64(path: String?, value: Int64, expected: Any.Type)
    /// Thrown when a floating-point value is coerced to a smaller type (e.g. `Double` to `Int`)
    /// and the value doesn't fit in the smaller type.
    /// - Parameter path: The path of the value that cuased the error.
    /// - Parameter value: The actual value at that path.
    /// - Parameter expected: The type that the value doesn't fit in, e.g. `Int.self`.
    case OutOfRangeDouble(path: String?, value: Double, expected: Any.Type)
    
    public var description: String {
        switch self {
        case let .MissingOrInvalidType(path, expected, actual): return "\(path.map({$0+": "}) ?? "")expected \(expected), found \(actual?.description ?? "missing value")"
        case let .OutOfRangeInt64(path, value, expected): return "\(path.map({$0+": "}) ?? "")value \(value) cannot be coerced to type \(expected)"
        case let .OutOfRangeDouble(path, value, expected): return "\(path.map({$0+": "}) ?? "")value \(value) cannot be coerced to type \(expected)"
        }
    }
    
    private func withPrefix(prefix: String) -> JSONError {
        func prefixPath(path: String?, with prefix: String) -> String {
            guard let path = path where !path.isEmpty else { return prefix }
            if path.unicodeScalars.first == "[" {
                return prefix + path
            } else {
                return "\(prefix).\(path)"
            }
        }
        switch self {
        case let .MissingOrInvalidType(path, expected, actual):
            return .MissingOrInvalidType(path: prefixPath(path, with: prefix), expected: expected, actual: actual)
        case let .OutOfRangeInt64(path, value, expected):
            return .OutOfRangeInt64(path: prefixPath(path, with: prefix), value: value, expected: expected)
        case let .OutOfRangeDouble(path, value, expected):
            return .OutOfRangeDouble(path: prefixPath(path, with: prefix), value: value, expected: expected)
        }
    }
    
    public enum ExpectedType: CustomStringConvertible {
        case Required(JSONType)
        case Optional(JSONType)
        
        public var description: String {
            switch self {
            case .Required(let type): return type.description
            case .Optional(let type): return "\(type) or null"
            }
        }
    }
    
    public enum JSONType: String, CustomStringConvertible {
        case Null = "null"
        case Bool = "bool"
        case String = "string"
        case Number = "number"
        case Object = "object"
        case Array = "array"
        
        internal static func forValue(value: JSON) -> JSONType {
            switch value {
            case .Null: return .Null
            case .Bool: return .Bool
            case .String: return .String
            case .Int64, .Double: return .Number
            case .Object: return .Object
            case .Array: return .Array
            }
        }
        
        public var description: Swift.String {
            return rawValue
        }
    }
}

// MARK: - Basic accessors
public extension JSON {
    /// Returns the bool value if the receiver is a bool.
    /// - Returns: A `Bool` value.
    /// - Throws: `JSONError` if the receiver is the wrong type.
    func getBool() throws -> Swift.Bool {
        guard let b = bool else { throw JSONError.MissingOrInvalidType(path: nil, expected: .Required(.Bool), actual: .forValue(self)) }
        return b
    }
    
    /// Returns the bool value if the receiver is a bool.
    /// - Returns: A `Bool` value, or `nil` if the receiver is `null`.
    /// - Throws: `JSONError` if the receiver is the wrong type.
    func getBoolOrNil() throws -> Swift.Bool? {
        if let b = bool { return b }
        else if isNull { return nil }
        else { throw JSONError.MissingOrInvalidType(path: nil, expected: .Optional(.Bool), actual: .forValue(self)) }
    }
    
    /// Returns the string value if the receiver is a string.
    /// - Returns: A `String` value.
    /// - Throws: `JSONError` if the receiver is the wrong type.
    func getString() throws -> Swift.String {
        guard let str = string else { throw JSONError.MissingOrInvalidType(path: nil, expected: .Required(.String), actual: .forValue(self)) }
        return str
    }
    
    /// Returns the string value if the receiver is a string.
    /// - Returns: A `String` value, or `nil` if the receiver is `null`.
    /// - Throws: `JSONError` if the receiver is the wrong type.
    func getStringOrNil() throws -> Swift.String? {
        if let str = string { return str }
        else if isNull { return nil }
        else { throw JSONError.MissingOrInvalidType(path: nil, expected: .Optional(.String), actual: .forValue(self)) }
    }
    
    /// Returns the 64-bit integral value if the receiver is a number.
    /// - Returns: An `Int64` value.
    /// - Throws: `JSONError` if the receiver is the wrong type.
    func getInt64() throws -> Swift.Int64 {
        guard let val = int64 else { throw JSONError.MissingOrInvalidType(path: nil, expected: .Required(.Number), actual: .forValue(self)) }
        return val
    }
    
    /// Returns the 64-bit integral value value if the receiver is a number.
    /// - Returns: An `Int64` value, or `nil` if the receiver is `null`.
    /// - Throws: `JSONError` if the receiver is the wrong type.
    func getInt64OrNil() throws -> Swift.Int64? {
        if let val = int64 { return val }
        else if isNull { return nil }
        else { throw JSONError.MissingOrInvalidType(path: nil, expected: .Optional(.Number), actual: .forValue(self)) }
    }
    
    /// Returns the integral value if the receiver is a number.
    /// - Returns: An `Int` value.
    /// - Throws: `JSONError` if the receiver is the wrong type, or if the 64-bit integral value
    ///   is too large to fit in an `Int`.
    func getInt() throws -> Int {
        guard let val = int64 else { throw JSONError.MissingOrInvalidType(path: nil, expected: .Required(.Number), actual: .forValue(self)) }
        let truncated = Int(truncatingBitPattern: val)
        guard Swift.Int64(truncated) == val else { throw JSONError.OutOfRangeInt64(path: nil, value: val, expected: Int.self) }
        return truncated
    }
    
    /// Returns the integral value if the receiver is a number.
    /// - Returns: An `Int` value, or `nil` if the receiver is `null`.
    /// - Throws: `JSONError` if the receiver is the wrong type, or if the 64-bit integral value
    ///   is too large to fit in an `Int`.
    func getIntOrNil() throws -> Int? {
        if let val = int64 {
            let truncated = Int(truncatingBitPattern: val)
            guard Swift.Int64(truncated) == val else { throw JSONError.OutOfRangeInt64(path: nil, value: val, expected: Int.self) }
            return truncated
        } else if isNull { return nil }
        else { throw JSONError.MissingOrInvalidType(path: nil, expected: .Optional(.Number), actual: .forValue(self)) }
    }
    
    /// Returns the double value if the receiver is a number.
    /// - Returns: A `Double` value.
    /// - Throws: `JSONError` if the receiver is the wrong type.
    func getDouble() throws -> Swift.Double {
        guard let val = double else { throw JSONError.MissingOrInvalidType(path: nil, expected: .Required(.Number), actual: .forValue(self)) }
        return val
    }
    
    /// Returns the double value if the receiver is a number.
    /// - Returns: A `Double` value, or `nil` if the receiver is `null`.
    /// - Throws: `JSONError` if the receiver is the wrong type.
    func getDoubleOrNil() throws -> Swift.Double? {
        if let val = double { return val }
        else if isNull { return nil }
        else { throw JSONError.MissingOrInvalidType(path: nil, expected: .Optional(.Number), actual: .forValue(self)) }
    }
    
    /// Returns the object value if the receiver is an object.
    /// - Returns: An object value.
    /// - Throws: `JSONError` if the receiver is the wrong type.
    func getObject() throws -> JSONObject {
        guard let dict = object else { throw JSONError.MissingOrInvalidType(path: nil, expected: .Required(.Object), actual: .forValue(self)) }
        return dict
    }
    
    /// Returns the object value if the receiver is an object.
    /// - Returns: An object value, or `nil` if the receiver is `null`.
    /// - Throws: `JSONError` if the receiver is the wrong type.
    func getObjectOrNil() throws -> JSONObject? {
        if let dict = object { return dict }
        else if isNull { return nil }
        else { throw JSONError.MissingOrInvalidType(path: nil, expected: .Optional(.Object), actual: .forValue(self)) }
    }
    
    /// Returns the array value if the receiver is an array.
    /// - Returns: An array value.
    /// - Throws: `JSONError` if the receiver is the wrong type.
    func getArray() throws -> JSONArray {
        guard let ary = array else { throw JSONError.MissingOrInvalidType(path: nil, expected: .Required(.Array), actual: .forValue(self)) }
        return ary
    }
    
    /// Returns the array value if the receiver is an array.
    /// - Returns: An array value, or `nil` if the receiver is `null`.
    /// - Throws: `JSONError` if the receiver is the wrong type.
    func getArrayOrNil() throws -> JSONArray? {
        if let ary = array { return ary }
        else if isNull { return nil }
        else { throw JSONError.MissingOrInvalidType(path: nil, expected: .Optional(.Array), actual: .forValue(self)) }
    }
}

public extension JSON {
    /// Returns the receiver coerced to a string value.
    /// - Returns: A `String` value.
    /// - Throws: `JSONError` if the receiver is an object or array.
    func toString() throws -> Swift.String {
        return try toStringMaybeNil(.Required(.String)) ?? "null"
    }
    
    /// Returns the receiver coerced to a string value.
    /// - Returns: A `String` value, or `nil` if the receiver is `null`.
    /// - Throws: `JSONError` if the receiver is an object or array.
    func toStringOrNil() throws -> Swift.String? {
        return try toStringMaybeNil(.Optional(.String))
    }
    
    private func toStringMaybeNil(expected: JSONError.ExpectedType) throws -> Swift.String? {
        switch self {
        case .String(let s): return s
        case .Null: return nil
        case .Bool(let b): return Swift.String(b)
        case .Int64(let i): return Swift.String(i)
        case .Double(let d): return Swift.String(d)
        default: throw JSONError.MissingOrInvalidType(path: nil, expected: expected, actual: .forValue(self))
        }
    }
    
    /// Returns the receiver coerced to a 64-bit integral value.
    /// If the receiver is a floating-point value, the value will be truncated
    /// to an integer.
    /// - Returns: An `Int64` value`.
    /// - Throws: `JSONError` if the receiver is `null`, a boolean, an object,
    ///   an array, a string that cannot be coerced to a 64-bit integral value,
    ///   or a floating-point value that does not fit in 64 bits.
    func toInt64() throws -> Swift.Int64 {
        guard let val = try toInt64MaybeNil(.Required(.Number)) else {
            throw JSONError.MissingOrInvalidType(path: nil, expected: .Required(.Number), actual: .Null)
        }
        return val
    }
    
    /// Returns the receiver coerced to a 64-bit integral value.
    /// If the receiver is a floating-point value, the value will be truncated
    /// to an integer.
    /// - Returns: An `Int64` value`, or `nil` if the receiver is `null`.
    /// - Throws: `JSONError` if the receiver is a boolean, an object, an array,
    ///   a string that cannot be coerced to a 64-bit integral value,
    ///   or a floating-point value that does not fit in 64 bits.
    func toInt64OrNil() throws -> Swift.Int64? {
        return try toInt64MaybeNil(.Optional(.Number))
    }
    
    private func toInt64MaybeNil(expected: JSONError.ExpectedType) throws -> Swift.Int64? {
        switch self {
        case .Int64(let i):
            return i
        case .Double(let d):
            guard let val = convertDoubleToInt64(d) else {
                throw JSONError.OutOfRangeDouble(path: nil, value: d, expected: Swift.Int64.self)
            }
            return val
        case .String(let s):
            if let i = Swift.Int64(s, radix: 10) {
                return i
            } else if let d = Swift.Double(s) {
                guard let val = convertDoubleToInt64(d) else {
                    throw JSONError.OutOfRangeDouble(path: nil, value: d, expected: Swift.Int64.self)
                }
                return val
            }
        case .Null:
            return nil
        default:
            break
        }
        throw JSONError.MissingOrInvalidType(path: nil, expected: expected, actual: .forValue(self))
    }
    
    /// Returns the receiver coerced to an integral value.
    /// If the receiver is a floating-point value, the value will be truncated
    /// to an integer.
    /// - Returns: An `Int` value`.
    /// - Throws: `JSONError` if the receiver is `null`, a boolean, an object,
    ///   an array, a string that cannot be coerced to an integral value,
    ///   or a floating-point value that does not fit in an `Int`.
    func toInt() throws -> Int {
        let val = try toInt64()
        let truncated = Int(truncatingBitPattern: val)
        guard Swift.Int64(truncated) == val else { throw JSONError.OutOfRangeInt64(path: nil, value: val, expected: Int.self) }
        return truncated
    }
    
    /// Returns the receiver coerced to an integral value.
    /// If the receiver is a floating-point value, the value will be truncated
    /// to an integer.
    /// - Returns: An `Int` value`, or `nil` if the receiver is `null`.
    /// - Throws: `JSONError` if the receiver is a boolean, an object,
    ///   an array, a string that cannot be coerced to an integral value,
    ///   or a floating-point value that does not fit in an `Int`.
    func toIntOrNil() throws -> Int? {
        guard let val = try toInt64OrNil() else { return nil }
        let truncated = Int(truncatingBitPattern: val)
        guard Swift.Int64(truncated) == val else { throw JSONError.OutOfRangeInt64(path: nil, value: val, expected: Int.self) }
        return truncated
    }
    
    /// Returns the receiver coerced to a `Double`.
    /// - Returns: A `Double` value.
    /// - Throws: `JSONError` if the receiver is `null`, a boolean, an object, an array,
    ///   or a string that cannot be coerced to a floating-point value.
    func toDouble() throws -> Swift.Double {
        guard let val = try toDoubleMaybeNil(.Required(.Number)) else {
            throw JSONError.MissingOrInvalidType(path: nil, expected: .Required(.Number), actual: .Null)
        }
        return val
    }
    
    /// Returns the receiver coerced to a `Double`.
    /// - Returns: A `Double` value, or `nil` if the receiver is `null`.
    /// - Throws: `JSONError` if the receiver is a boolean, an object, an array,
    ///   or a string that cannot be coerced to a floating-point value.
    func toDoubleOrNil() throws -> Swift.Double? {
        return try toDoubleMaybeNil(.Optional(.Number))
    }
    
    private func toDoubleMaybeNil(expected: JSONError.ExpectedType) throws -> Swift.Double? {
        switch self {
        case .Int64(let i): return Swift.Double(i)
        case .Double(let d): return d
        case .String(let s): return Swift.Double(s)
        case .Null: return nil
        default: throw JSONError.MissingOrInvalidType(path: nil, expected: expected, actual: .forValue(self))
        }
    }
}

// MARK: - Keyed accessors
public extension JSON {
    /// Subscripts the receiver with `key` and returns the result.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: A `Bool` value.
    /// - Throws: `JSONError` if the key doesn't exist or the value is the wrong type, or if
    ///   the receiver is not an object.
    func getBool(key: Swift.String) throws -> Swift.Bool {
        let dict = try getObject()
        let value = try getRequired(dict, key: key, type: .String)
        return try scoped(key) { try value.getBool() }
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: A `Bool` value, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type, or if the receiver is not an object.
    func getBoolOrNil(key: Swift.String) throws -> Swift.Bool? {
        let dict = try getObject()
        guard let value = dict[key] else { return nil }
        return try scoped(key) { try value.getBoolOrNil() }
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: A `String` value.
    /// - Throws: `JSONError` if the key doesn't exist or the value is the wrong type, or if
    ///   the receiver is not an object.
    func getString(key: Swift.String) throws -> Swift.String {
        let dict = try getObject()
        let value = try getRequired(dict, key: key, type: .String)
        return try scoped(key) { try value.getString() }
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: A `String` value, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type, or if the receiver is not an object.
    func getStringOrNil(key: Swift.String) throws -> Swift.String? {
        let dict = try getObject()
        guard let value = dict[key] else { return nil }
        return try scoped(key) { try value.getStringOrNil() }
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: An `Int64` value.
    /// - Throws: `JSONError` if the key doesn't exist or the value is the wrong type, or if
    ///   the receiver is not an object.
    func getInt64(key: Swift.String) throws -> Swift.Int64 {
        let dict = try getObject()
        let value = try getRequired(dict, key: key, type: .Number)
        return try scoped(key) { try value.getInt64() }
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: An `Int64` value, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type, or if the receiver is not an object.
    func getInt64OrNil(key: Swift.String) throws -> Swift.Int64? {
        let dict = try getObject()
        guard let value = dict[key] else { return nil }
        return try scoped(key) { try value.getInt64OrNil() }
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: An `Int` value.
    /// - Throws: `JSONError` if the key doesn't exist or the value is the wrong type,
    ///   or if the 64-bit integral value is too large to fit in an `Int`, or if
    ///   the receiver is not an object.
    func getInt(key: Swift.String) throws -> Int {
        let dict = try getObject()
        let value = try getRequired(dict, key: key, type: .Number)
        return try scoped(key) { try value.getInt() }
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: An `Int` value, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type, or if the 64-bit integral
    ///   value is too large to fit in an `Int`, or if the receiver is not an object.
    func getIntOrNil(key: Swift.String) throws -> Int? {
        let dict = try getObject()
        guard let value = dict[key] else { return nil }
        return try scoped(key) { try value.getIntOrNil() }
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: A `Double` value.
    /// - Throws: `JSONError` if the key doesn't exist or the value is the wrong type, or if
    ///   the receiver is not an object.
    func getDouble(key: Swift.String) throws -> Swift.Double {
        let dict = try getObject()
        let value = try getRequired(dict, key: key, type: .Number)
        return try scoped(key) { try value.getDouble() }
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: A `Double` value, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type, or if the receiver is not an object.
    func getDoubleOrNil(key: Swift.String) throws -> Swift.Double? {
        let dict = try getObject()
        guard let value = dict[key] else { return nil }
        return try scoped(key) { try value.getDoubleOrNil() }
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Note: Use `getObject(_:_:)` when using throwing accessors on the resulting
    ///   object value to produce better errors.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: An object value.
    /// - Throws: `JSONError` if the key doesn't exist or the value is the wrong type, or if
    ///   the receiver is not an object.
    /// - SeeAlso: `getObject(_:_:)`
    func getObject(key: Swift.String) throws -> JSONObject {
        return try getObject(key, { $0 })
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Note: Use `getObjectOrNil(_:_:)` when using throwing accessors on the resulting
    ///   object value to produce better errors.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: An object value, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type, or if the receiver is not an object.
    /// - SeeAlso: `getObjectOrNil(_:_:)`
    func getObjectOrNil(key: Swift.String) throws -> JSONObject? {
        return try getObjectOrNil(key, { $0 })
    }
    
    /// Subscripts the receiver with `key` and passes the result to the given block.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Parameter transform: A block that's called with the result of subscripting the receiver with `key`.
    /// - Returns: The result of calling the given block.
    /// - Throws: `JSONError` if the key doesn't exist or the value is the wrong type, or if
    ///   the receiver is not an object, or any error thrown by `transform`.
    func getObject<T>(key: Swift.String, @noescape _ transform: JSONObject throws -> T) throws -> T {
        return try getObject().getObject(key, transform)
    }
    
    /// Subscripts the receiver with `key` and passes the result to the given block.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Parameter transform: A block that's called with the result of subscripting the receiver with `key`.
    /// - Returns: The result of calling the given block, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type, or if the receiver is not an object,
    ///   or any error thrown by `transform`.
    func getObjectOrNil<T>(key: Swift.String, @noescape _ transform: JSONObject throws -> T?) throws -> T? {
        return try getObject().getObjectOrNil(key, transform)
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Note: Use `getArray(_:_:)` when using throwing accessors on the resulting
    ///   array value to produce better errors.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Throws: `JSONError` if the key doesn't exist or the value is the wrong type, or if
    ///   the receiver is not an object.
    /// - SeeAlso: `getArray(_:_:)`
    func getArray(key: Swift.String) throws -> JSONArray {
        return try getArray(key, { $0 })
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Note: Use `getArrayOrNil(_:_:)` when using throwing accessors on the resulting
    ///   array value to produce better errors.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: An array value, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type.
    /// - SeeAlso: `getArrayOrNil(_:_:)`
    func getArrayOrNil(key: Swift.String) throws -> JSONArray? {
        return try getArrayOrNil(key, { $0 })
    }
    
    /// Subscripts the receiver with `key` and passes the result to the given block.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Parameter transform: A block that's called with the result of subscripting the receiver with `key`.
    /// - Returns: The result of calling the given block.
    /// - Throws: `JSONError` if the key doesn't exist or the value is the wrong type, or if
    ///   the receiver is not an object, or any error thrown by `transform`.
    func getArray<T>(key: Swift.String, @noescape _ transform: JSONArray throws -> T) throws -> T {
        let dict = try getObject()
        let value = try getRequired(dict, key: key, type: .Array)
        return try scoped(key) { try transform(value.getArray()) }
    }
    
    /// Subscripts the receiver with `key` and passes the result to the given block.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Parameter transform: A block that's called with the result of subscripting the receiver with `key`.
    /// - Returns: The result of calling the given block, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type, or if the receiver is not an object,
    ///   or any error thrown by `transform`.
    func getArrayOrNil<T>(key: Swift.String, @noescape _ transform: JSONArray throws -> T?) throws -> T? {
        let dict = try getObject()
        guard let value = dict[key] else { return nil }
        return try scoped(key) { try value.getArrayOrNil().flatMap(transform) }
    }
}

public extension JSON {
    /// Subscripts the receiver with `key` and returns the result coerced to a `String`.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: A `String` value.
    /// - Throws: `JSONError` if the key doesn't exist, the value is an object or an array,
    ///   or if the receiver is not an object.
    /// - SeeAlso: `toString()`.
    func toString(key: Swift.String) throws -> Swift.String {
        let dict = try getObject()
        let value = try getRequired(dict, key: key, type: .String)
        return try scoped(key) { try value.toString() }
    }
    
    /// Subscripts the receiver with `key` and returns the result coerced to a `String`.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: A `String` value, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the value is an object or an array, or if the receiver is not an object.
    /// - SeeAlso: `toStringOrNil()`.
    func toStringOrNil(key: Swift.String) throws -> Swift.String? {
        let dict = try getObject()
        guard let value = dict[key] else { return nil }
        return try scoped(key) { try value.toStringOrNil() }
    }
    
    /// Subscripts the receiver with `key` and returns the result coerced to an `Int64`.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: An `Int64` value.
    /// - Throws: `JSONError` if the key doesn't exist or the value is `null`, a boolean, an object,
    ///   an array, a string that cannot be coerced to a 64-bit integral value, or a floating-point
    ///   value that does not fit in 64 bits, or if the receiver is not an object.
    func toInt64(key: Swift.String) throws -> Swift.Int64 {
        let dict = try getObject()
        let value = try getRequired(dict, key: key, type: .Number)
        return try scoped(key) { try value.toInt64() }
    }
    
    /// Subscripts the receiver with `key` and returns the result coerced to an `Int64`.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: An `Int64` value, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the the value is a boolean, an object, an array, a string
    ///   that cannot be coerced to a 64-bit integral value, or a floating-point value
    ///   that does not fit in 64 bits, or if the receiver is not an object.
    func toInt64OrNil(key: Swift.String) throws -> Swift.Int64? {
        let dict = try getObject()
        guard let value = dict[key] else { return nil }
        return try scoped(key) { try value.toInt64OrNil() }
    }
    
    /// Subscripts the receiver with `key` and returns the result coerced to an `Int`.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: An `Int` value.
    /// - Throws: `JSONError` if the key doesn't exist or the value is `null`, a boolean, an object,
    ///   an array, a string that cannot be coerced to an integral value, or a floating-point
    ///   value that does not fit in an `Int`, or if the receiver is not an object.
    func toInt(key: Swift.String) throws -> Int {
        let dict = try getObject()
        let value = try getRequired(dict, key: key, type: .Number)
        return try scoped(key) { try value.toInt() }
    }
    
    /// Subscripts the receiver with `key` and returns the result coerced to an `Int`.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: An `Int` value, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the the value is a boolean, an object, an array, a string
    ///   that cannot be coerced to an integral value, or a floating-point value
    ///   that does not fit in an `Int`, or if the receiver is not an object.
    func toIntOrNil(key: Swift.String) throws -> Int? {
        let dict = try getObject()
        guard let value = dict[key] else { return nil }
        return try scoped(key) { try value.toIntOrNil() }
    }
    
    /// Subscripts the receiver with `key` and returns the result coerced to a `Double`.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: A `Double` value.
    /// - Throws: `JSONError` if the key doesn't exist or the value is `null`, a boolean,
    ///   an object, an array, or a string that cannot be coerced to a floating-point value,
    ///   or if the receiver is not an object.
    func toDouble(key: Swift.String) throws -> Swift.Double {
        let dict = try getObject()
        let value = try getRequired(dict, key: key, type: .Number)
        return try scoped(key) { try value.toDouble() }
    }
    
    /// Subscripts the receiver with `key` and returns the result coerced to a `Double`.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: A `Double` value, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the value is a boolean, an object, an array, or a string that
    ///   cannot be coerced to a floating-point value, or if the receiver is not an object.
    func toDoubleOrNil(key: Swift.String) throws -> Swift.Double? {
        let dict = try getObject()
        guard let value = dict[key] else { return nil }
        return try scoped(key) { try value.toDoubleOrNil() }
    }
}

// MARK: - Indexed accessors
public extension JSON {
    /// Subscripts the receiver with `index` and returns the result.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Returns: A `Bool` value.
    /// - Throws: `JSONError` if the index is out of bounds or the value is the wrong type,
    ///   or if the receiver is not an array.
    func getBool(index: Int) throws -> Swift.Bool {
        let ary = try getArray()
        let value = try getRequired(ary, index: index, type: .Bool)
        return try scoped(index) { try value.getBool() }
    }
    
    /// Subscripts the receiver with `index` and returns the result.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Returns: A `Bool` value, or `nil` if the index is out of bounds or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type, or if the receiver is not an array.
    func getBoolOrNil(index: Int) throws -> Swift.Bool? {
        let ary = try getArray()
        guard let value = ary[safe: index] else { return nil }
        return try scoped(index) { try value.getBoolOrNil() }
    }
    
    /// Subscripts the receiver with `index` and returns the result.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Returns: A `String` value.
    /// - Throws: `JSONError` if the index is out of bounds or the value is the wrong type,
    ///   or if the receiver is not an array.
    func getString(index: Int) throws -> Swift.String {
        let ary = try getArray()
        let value = try getRequired(ary, index: index, type: .String)
        return try scoped(index) { try value.getString() }
    }
    
    /// Subscripts the receiver with `index` and returns the result.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Returns: A `String` value, or `nil` if the index is out of bounds or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type, or if the receiver is not an array.
    func getStringOrNil(index: Int) throws -> Swift.String? {
        let ary = try getArray()
        guard let value = ary[safe: index] else { return nil }
        return try scoped(index) { try value.getStringOrNil() }
    }
    
    /// Subscripts the receiver with `index` and returns the result.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Returns: An `Int64` value.
    /// - Throws: `JSONError` if the index is out of bounds or the value is the wrong type,
    ///   or if the receiver is not an array.
    func getInt64(index: Int) throws -> Swift.Int64 {
        let ary = try getArray()
        let value = try getRequired(ary, index: index, type: .Number)
        return try scoped(index) { try value.getInt64() }
    }
    
    /// Subscripts the receiver with `index` and returns the result.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Returns: An `Int64` value, or `nil` if the index is out of bounds or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type, or if the receiver is not an array.
    func getInt64OrNil(index: Int) throws -> Swift.Int64? {
        let ary = try getArray()
        guard let value = ary[safe: index] else { return nil }
        return try scoped(index) { try value.getInt64OrNil() }
    }
    
    /// Subscripts the receiver with `index` and returns the result.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Returns: An `Int` value.
    /// - Throws: `JSONError` if the index is out of bounds or the value is the wrong type,
    ///   or if the 64-bit integral value is too large to fit in an `Int`, or if
    ///   the receiver is not an array.
    func getInt(index: Int) throws -> Int {
        let ary = try getArray()
        let value = try getRequired(ary, index: index, type: .Number)
        return try scoped(index) { try value.getInt() }
    }
    
    /// Subscripts the receiver with `index` and returns the result.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Returns: An `Int` value, or `nil` if the index is out of bounds or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type, or if the 64-bit integral value
    ///   is too large to fit in an `Int`, or if the receiver is not an array.
    func getIntOrNil(index: Int) throws -> Int? {
        let ary = try getArray()
        guard let value = ary[safe: index] else { return nil }
        return try scoped(index) { try value.getIntOrNil() }
    }
    
    /// Subscripts the receiver with `index` and returns the result.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Returns: A `Double` value.
    /// - Throws: `JSONError` if the index is out of bounds or the value is the wrong type,
    ///   or if the receiver is not an array.
    func getDouble(index: Int) throws -> Swift.Double {
        let ary = try getArray()
        let value = try getRequired(ary, index: index, type: .Number)
        return try scoped(index) { try value.getDouble() }
    }
    
    /// Subscripts the receiver with `index` and returns the result.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Returns: A `Double` value, or `nil` if the index is out of bounds or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type, or if the receiver is not an array.
    func getDoubleOrNil(index: Int) throws -> Swift.Double? {
        let ary = try getArray()
        guard let value = ary[safe: index] else { return nil }
        return try scoped(index) { try value.getDoubleOrNil() }
    }
    
    /// Subscripts the receiver with `index` and returns the result.
    /// - Note: Use `getObject(_:_:)` when using throwing accessors on the resulting
    ///   object value to produce better errors.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Returns: An object value.
    /// - Throws: `JSONError` if the index is out of bounds or the value is the wrong type,
    ///   or if the receiver is not an array.
    /// - SeeAlso: `getObject(_:_:)`
    func getObject(index: Int) throws -> JSONObject {
        return try getObject(index, { $0 })
    }
    
    /// Subscripts the receiver with `index` and returns the result.
    /// - Note: Use `getObjectOrNil(_:_:)` when using throwing accessors on the resulting
    ///   object value to produce better errors.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Returns: An object value, or `nil` if the index is out of bounds or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type, or if the receiver is not an array.
    /// - SeeAlso: `getObjectOrNil(_:_:)`
    func getObjectOrNil(index: Int) throws -> JSONObject? {
        return try getObjectOrNil(index, { $0 })
    }
    
    /// Subscripts the receiver with `index` and passes the result to the given block.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Parameter transform: A block that's called with the result of subscripting the receiver with `index`.
    /// - Returns: The result of calling the given block.
    /// - Throws: `JSONError` if the index is out of bounds or the value is the wrong type,
    ///   or if the receiver is not an array, or any error thrown by `transform`.
    func getObject<T>(index: Int, @noescape _ f: JSONObject throws -> T) throws -> T {
        let ary = try getArray()
        let value = try getRequired(ary, index: index, type: .Object)
        return try scoped(index) { try f(value.getObject()) }
    }
    
    /// Subscripts the receiver with `index` and passes the result to the given block.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Parameter transform: A block that's called with the result of subscripting the receiver with `index`.
    /// - Returns: The result of calling the given block, or `nil` if the index is out of bounds or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type, or if the receiver is not an array,
    ////  or any error thrown by `transform`.
    func getObjectOrNil<T>(index: Int, @noescape _ f: JSONObject throws -> T?) throws -> T? {
        let ary = try getArray()
        guard let value = ary[safe: index] else { return nil }
        return try scoped(index) { try value.getObjectOrNil().flatMap(f) }
    }
    
    /// Subscripts the receiver with `index` and returns the result.
    /// - Note: Use `getArray(_:_:)` when using throwing accessors on the resulting
    ///   array value to produce better errors.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Returns: An array value.
    /// - Throws: `JSONError` if the index is out of bounds or the value is the wrong type,
    ///   or if the receiver is not an array.
    /// - SeeAlso: `getArray(_:_:)`
    func getArray(index: Int) throws -> JSONArray {
        return try getArray(index, { $0 })
    }
    
    /// Subscripts the receiver with `index` and returns the result.
    /// - Note: Use `getArrayOrNil(_:_:)` when using throwing accessors on the resulting
    ///   array value to produce better errors.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Returns: An array value, or `nil` if the index is out of bounds or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type, or if the receiver is not an array.
    /// - SeeAlso: `getArrayOrNil(_:_:)`
    func getArrayOrNil(index: Int) throws -> JSONArray? {
        return try getArrayOrNil(index, { $0 })
    }
    
    /// Subscripts the receiver with `index` and passes the result to the given block.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Parameter transform: A block that's called with the result of subscripting the receiver with `index`.
    /// - Returns: The result of calling the given block.
    /// - Throws: `JSONError` if the index is out of bounds or the value is the wrong type,
    ///   or if the receiver is not an array, or any error thrown by `transform`.
    func getArray<T>(index: Int, @noescape _ f: JSONArray throws -> T) throws -> T {
        let ary = try getArray()
        let value = try getRequired(ary, index: index, type: .Array)
        return try scoped(index) { try f(value.getArray()) }
    }
    
    /// Subscripts the receiver with `index` and passes the result to the given block.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Parameter transform: A block that's called with the result of subscripting the receiver with `index`.
    /// - Returns: The result of calling the given block, or `nil` if the index is out of bounds or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type, or if the receiver is not an array,
    ///   or any error thrown by `transform`.
    func getArrayOrNil<T>(index: Int, @noescape _ f: JSONArray throws -> T?) throws -> T? {
        let ary = try getArray()
        guard let value = ary[safe: index] else { return nil }
        return try scoped(index) { try value.getArrayOrNil().flatMap(f) }
    }
}

public extension JSON {
    /// Subscripts the receiver with `index` and returns the result coerced to a `String`.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Returns: A `String` value.
    /// - Throws: `JSONError` if the index is out of bounds or the value is an object or an array,
    ///   or if the receiver is not an array.
    /// - SeeAlso: `toString()`.
    func toString(index: Int) throws -> Swift.String {
        let ary = try getArray()
        let value = try getRequired(ary, index: index, type: .String)
        return try scoped(index) { try value.toString() }
    }
    
    /// Subscripts the receiver with `index` and returns the result coerced to a `String`.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Returns: A `String` value, or `nil` if the index is out of bounds or the value is `null`.
    /// - Throws: `JSONError` if the value is an object or an array, or if the receiver is not an array.
    /// - SeeAlso: `toStringOrNil()`.
    func toStringOrNil(index: Int) throws -> Swift.String? {
        let ary = try getArray()
        guard let value = ary[safe: index] else { return nil }
        return try scoped(index) { try value.toStringOrNil() }
    }
    
    /// Subscripts the receiver with `index` and returns the result coerced to an `Int64`.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Returns: An `Int64` value.
    /// - Throws: `JSONError` if the index is out of bounds or the value is `null`, a boolean,
    ///   an object, an array, a string that cannot be coerced to a 64-bit integral value, or a
    ///   floating-point value that does not fit in 64 bits, or if the receiver is not an array.
    /// - SeeAlso: `toInt64()`.
    func toInt64(index: Int) throws -> Swift.Int64 {
        let ary = try getArray()
        let value = try getRequired(ary, index: index, type: .Number)
        return try scoped(index) { try value.toInt64() }
    }
    
    /// Subscripts the receiver with `index` and returns the result coerced to an `Int64`.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Returns: An `Int64` value, or `nil` if the index is out of bounds or the value is `null`.
    /// - Throws: `JSONError` if the the value is a boolean, an object, an array, a string
    ///   that cannot be coerced to a 64-bit integral value, or a floating-point value
    ///   that does not fit in 64 bits, or if the receiver is not an array.
    /// - SeeAlso: `toInt64OrNil()`.
    func toInt64OrNil(index: Int) throws -> Swift.Int64? {
        let ary = try getArray()
        guard let value = ary[safe: index] else { return nil }
        return try scoped(index) { try value.toInt64OrNil() }
    }
    
    /// Subscripts the receiver with `index` and returns the result coerced to an `Int`.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Returns: An `Int` value.
    /// - Throws: `JSONError` if the index is out of bounds or the value is `null`, a boolean,
    ///   an object, an array, a string that cannot be coerced to an integral value, or a
    ///   floating-point value that does not fit in an `Int`, or if the receiver is not an array.
    /// - SeeAlso: `toInt()`.
    func toInt(index: Int) throws -> Int {
        let ary = try getArray()
        let value = try getRequired(ary, index: index, type: .Number)
        return try scoped(index) { try value.toInt() }
    }
    
    /// Subscripts the receiver with `index` and returns the result coerced to an `Int`.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Returns: An `Int` value, or `nil` if the index is out of bounds or the value is `null`.
    /// - Throws: `JSONError` if the the value is a boolean, an object, an array, a string
    ///   that cannot be coerced to an integral value, or a floating-point value
    ///   that does not fit in an `Int`, or if the receiver is not an array.
    /// - SeeAlso: `toIntOrNil()`.
    func toIntOrNil(index: Int) throws -> Int? {
        let ary = try getArray()
        guard let value = ary[safe: index] else { return nil }
        return try scoped(index) { try value.toIntOrNil() }
    }
    
    /// Subscripts the receiver with `index` and returns the result coerced to a `Double`.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Returns: A `Double` value.
    /// - Throws: `JSONError` if the index is out of bounds or the value is `null`, a boolean,
    ///   an object, an array, or a string that cannot be coerced to a floating-point value,
    ///   or if the receiver is not an array.
    /// - SeeAlso: `toDouble()`.
    func toDouble(index: Int) throws -> Swift.Double {
        let ary = try getArray()
        let value = try getRequired(ary, index: index, type: .Number)
        return try scoped(index) { try value.toDouble() }
    }
    
    /// Subscripts the receiver with `index` and returns the result coerced to a `Double`.
    /// - Parameter index: The index that's used to subscript the receiver.
    /// - Returns: A `Double` value, or `nil` if the index is out of bounds or the value is `null`.
    /// - Throws: `JSONError` if the value is a boolean, an object, an array, or a string that
    ///   cannot be coerced to a floating-point value, or if the receiver is not an array.
    /// - SeeAlso: `toDouble()`.
    func toDoubleOrNil(index: Int) throws -> Swift.Double? {
        let ary = try getArray()
        guard let value = ary[safe: index] else { return nil }
        return try scoped(index) { try value.toDoubleOrNil() }
    }
}

// MARK: -

public extension JSONObject {
    /// Subscripts the receiver with `key` and returns the result.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: A `Bool` value.
    /// - Throws: `JSONError` if the key doesn't exist or the value is the wrong type.
    func getBool(key: Swift.String) throws -> Swift.Bool {
        let value = try getRequired(self, key: key, type: .String)
        return try scoped(key) { try value.getBool() }
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: A `Bool` value, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type.
    func getBoolOrNil(key: Swift.String) throws -> Swift.Bool? {
        guard let value = self[key] else { return nil }
        return try scoped(key) { try value.getBoolOrNil() }
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: A `String` value.
    /// - Throws: `JSONError` if the key doesn't exist or the value is the wrong type.
    func getString(key: Swift.String) throws -> Swift.String {
        let value = try getRequired(self, key: key, type: .String)
        return try scoped(key) { try value.getString() }
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: A `String` value, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type.
    func getStringOrNil(key: Swift.String) throws -> Swift.String? {
        guard let value = self[key] else { return nil }
        return try scoped(key) { try value.getStringOrNil() }
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: An `Int64` value.
    /// - Throws: `JSONError` if the key doesn't exist or the value is the wrong type.
    func getInt64(key: Swift.String) throws -> Swift.Int64 {
        let value = try getRequired(self, key: key, type: .Number)
        return try scoped(key) { try value.getInt64() }
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: An `Int64` value, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type.
    func getInt64OrNil(key: Swift.String) throws -> Swift.Int64? {
        guard let value = self[key] else { return nil }
        return try scoped(key) { try value.getInt64OrNil() }
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: An `Int` value.
    /// - Throws: `JSONError` if the key doesn't exist or the value is the wrong type,
    ///   or if the 64-bit integral value is too large to fit in an `Int`.
    func getInt(key: Swift.String) throws -> Int {
        let value = try getRequired(self, key: key, type: .Number)
        return try scoped(key) { try value.getInt() }
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: An `Int` value, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type, or if the 64-bit integral
    ///   value is too large to fit in an `Int`.
    func getIntOrNil(key: Swift.String) throws -> Int? {
        guard let value = self[key] else { return nil }
        return try scoped(key) { try value.getIntOrNil() }
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: A `Double` value.
    /// - Throws: `JSONError` if the key doesn't exist or the value is the wrong type.
    func getDouble(key: Swift.String) throws -> Swift.Double {
        let value = try getRequired(self, key: key, type: .Number)
        return try scoped(key) { try value.getDouble() }
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: A `Double` value, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type.
    func getDoubleOrNil(key: Swift.String) throws -> Swift.Double? {
        guard let value = self[key] else { return nil }
        return try scoped(key) { try value.getDoubleOrNil() }
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Note: Use `getObject(_:_:)` when using throwing accessors on the resulting
    ///   object value to produce better errors.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: An object value.
    /// - Throws: `JSONError` if the key doesn't exist or the value is the wrong type.
    /// - SeeAlso: `getObject(_:_:)`
    func getObject(key: Swift.String) throws -> JSONObject {
        return try getObject(key, { $0 })
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Note: Use `getObjectOrNil(_:_:)` when using throwing accessors on the resulting
    ///   object value to produce better errors.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: An object value, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type.
    /// - SeeAlso: `getObjectOrNil(_:_:)`
    func getObjectOrNil(key: Swift.String) throws -> JSONObject? {
        return try getObjectOrNil(key, { $0 })
    }
    
    /// Subscripts the receiver with `key` and passes the result to the given block.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Parameter transform: A block that's called with the result of subscripting the receiver with `key`.
    /// - Returns: The result of calling the given block.
    /// - Throws: `JSONError` if the key doesn't exist or the value is the wrong type, or any
    ///   error thrown by `transform`.
    func getObject<T>(key: Swift.String, @noescape _ f: JSONObject throws -> T) throws -> T {
        let value = try getRequired(self, key: key, type: .Object)
        return try scoped(key) { try f(value.getObject()) }
    }
    
    /// Subscripts the receiver with `key` and passes the result to the given block.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Parameter transform: A block that's called with the result of subscripting the receiver with `key`.
    /// - Returns: The result of calling the given block, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type, or any error thrown by `transform`.
    func getObjectOrNil<T>(key: Swift.String, @noescape _ f: JSONObject throws -> T?) throws -> T? {
        guard let value = self[key] else { return nil }
        return try scoped(key) { try value.getObjectOrNil().flatMap(f) }
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Note: Use `getArray(_:_:)` when using throwing accessors on the resulting
    ///   array value to produce better errors.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Throws: `JSONError` if the key doesn't exist or the value is the wrong type.
    /// - SeeAlso: `getArray(_:_:)`
    func getArray(key: Swift.String) throws -> JSONArray {
        return try getArray(key, { $0 })
    }
    
    /// Subscripts the receiver with `key` and returns the result.
    /// - Note: Use `getArrayOrNil(_:_:)` when using throwing accessors on the resulting
    ///   array value to produce better errors.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: An array value, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type.
    /// - SeeAlso: `getArrayOrNil(_:_:)`
    func getArrayOrNil(key: Swift.String) throws -> JSONArray? {
        return try getArrayOrNil(key, { $0 })
    }
    
    /// Subscripts the receiver with `key` and passes the result to the given block.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Parameter transform: A block that's called with the result of subscripting the receiver with `key`.
    /// - Returns: The result of calling the given block.
    /// - Throws: `JSONError` if the key doesn't exist or the value is the wrong type, or any
    ///   error thrown by `transform`.
    func getArray<T>(key: Swift.String, @noescape _ f: JSONArray throws -> T) throws -> T {
        let value = try getRequired(self, key: key, type: .Array)
        return try scoped(key) { try f(value.getArray()) }
    }
    
    /// Subscripts the receiver with `key` and passes the result to the given block.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Parameter transform: A block that's called with the result of subscripting the receiver with `key`.
    /// - Returns: The result of calling the given block, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the value has the wrong type, or any error thrown by `transform`.
    func getArrayOrNil<T>(key: Swift.String, @noescape _ f: JSONArray throws -> T?) throws -> T? {
        guard let value = self[key] else { return nil }
        return try scoped(key) { try value.getArrayOrNil().flatMap(f) }
    }
}

public extension JSONObject {
    /// Subscripts the receiver with `key` and returns the result coerced to a `String`.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: A `String` value.
    /// - Throws: `JSONError` if the key doesn't exist, the value is an object or an array,
    ///   or if the receiver is not an object.
    /// - SeeAlso: `toString()`.
    func toString(key: Swift.String) throws -> Swift.String {
        let value = try getRequired(self, key: key, type: .String)
        return try scoped(key) { try value.toString() }
    }
    
    /// Subscripts the receiver with `key` and returns the result coerced to a `String`.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: A `String` value, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the value is an object or an array, or if the receiver is not an object.
    /// - SeeAlso: `toStringOrNil()`.
    func toStringOrNil(key: Swift.String) throws -> Swift.String? {
        guard let value = self[key] else { return nil }
        return try scoped(key) { try value.toStringOrNil() }
    }
    
    /// Subscripts the receiver with `key` and returns the result coerced to an `Int64`.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: An `Int64` value.
    /// - Throws: `JSONError` if the key doesn't exist or the value is `null`, a boolean, an object,
    ///   an array, a string that cannot be coerced to a 64-bit integral value, or a floating-point
    ///   value that does not fit in 64 bits, or if the receiver is not an object.
    func toInt64(key: Swift.String) throws -> Swift.Int64 {
        let value = try getRequired(self, key: key, type: .Number)
        return try scoped(key) { try value.toInt64() }
    }
    
    /// Subscripts the receiver with `key` and returns the result coerced to an `Int64`.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: An `Int64` value, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the the value is a boolean, an object, an array, a string
    ///   that cannot be coerced to a 64-bit integral value, or a floating-point value
    ///   that does not fit in 64 bits, or if the receiver is not an object.
    func toInt64OrNil(key: Swift.String) throws -> Swift.Int64? {
        guard let value = self[key] else { return nil }
        return try scoped(key) { try value.toInt64OrNil() }
    }
    
    /// Subscripts the receiver with `key` and returns the result coerced to an `Int`.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: An `Int` value.
    /// - Throws: `JSONError` if the key doesn't exist or the value is `null`, a boolean, an object,
    ///   an array, a string that cannot be coerced to an integral value, or a floating-point
    ///   value that does not fit in an `Int`, or if the receiver is not an object.
    func toInt(key: Swift.String) throws -> Int {
        let value = try getRequired(self, key: key, type: .Number)
        return try scoped(key) { try value.toInt() }
    }
    
    /// Subscripts the receiver with `key` and returns the result coerced to an `Int`.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: An `Int` value, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the the value is a boolean, an object, an array, a string
    ///   that cannot be coerced to an integral value, or a floating-point value
    ///   that does not fit in an `Int`, or if the receiver is not an object.
    func toIntOrNil(key: Swift.String) throws -> Int? {
        guard let value = self[key] else { return nil }
        return try scoped(key) { try value.toIntOrNil() }
    }
    
    /// Subscripts the receiver with `key` and returns the result coerced to a `Double`.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: A `Double` value.
    /// - Throws: `JSONError` if the key doesn't exist or the value is `null`, a boolean,
    ///   an object, an array, or a string that cannot be coerced to a floating-point value,
    ///   or if the receiver is not an object.
    func toDouble(key: Swift.String) throws -> Swift.Double {
        let value = try getRequired(self, key: key, type: .Number)
        return try scoped(key) { try value.toDouble() }
    }
    
    /// Subscripts the receiver with `key` and returns the result coerced to a `Double`.
    /// - Parameter key: The key that's used to subscript the receiver.
    /// - Returns: A `Double` value, or `nil` if the key doesn't exist or the value is `null`.
    /// - Throws: `JSONError` if the value is a boolean, an object, an array, or a string that
    ///   cannot be coerced to a floating-point value, or if the receiver is not an object.
    func toDoubleOrNil(key: Swift.String) throws -> Swift.Double? {
        guard let value = self[key] else { return nil }
        return try scoped(key) { try value.toDoubleOrNil() }
    }
}

// MARK: - JSONArray helpers

// FIXME: Swift 3: Use `rethrows`.
public extension JSON {
    /// Returns an `Array` containing the results of mapping `transform` over `array`.
    ///
    /// If `transform` throws a `JSONError`, the error will be modified to include the index
    /// of the element that caused the error.
    ///
    /// - Parameter array: The `JSONArray` to map over.
    /// - Parameter transform: A block that is called once for each element of `array`.
    /// - Returns: An array with the results of mapping `transform` over `array`.
    /// - Throws: Rethrows any error thrown by `transform`.
    /// - Complexity: O(*N*).
    /// - Bug: This method must be marked as `throws` instead of `rethrows` because of Swift compiler
    ///   limitations. If you want to map an array with a non-throwing transform function, use
    ///   `SequenceType.map` instead.
    static func map<T>(array: JSONArray, @noescape _ transform: JSON throws -> T) throws -> [T] {
        return try array.enumerate().map({ i, elt in try scoped(i, f: { try transform(elt) }) })
    }
    
    /// Returns an `Array` containing the non-`nil` results of mapping `transform` over `array`.
    ///
    /// If `transform` throws a `JSONError`, the error will be modified to include the index
    /// of the element that caused the error.
    ///
    /// - Parameter array: The `JSONArray` to map over.
    /// - Parameter transform: A block that is called once for each element of `array`.
    /// - Returns: An array with the non-`nil` results of mapping `transform` over `array`.
    /// - Throws: Rethrows any error thrown by `transform`.
    /// - Complexity: O(*N*).
    /// - Bug: This method must be marked as `throws` instead of `rethrows` because of Swift compiler
    ///   limitations. If you want to map an array with a non-throwing transform function, use
    ///   `SequenceType.flatMap` instead.
    static func flatMap<T>(array: JSONArray, @noescape _ transform: JSON throws -> T?) throws -> [T] {
        return try array.enumerate().flatMap({ i, elt in try scoped(i, f: { try transform(elt) }) })
    }
    
    /// Returns an `Array` containing the concatenated results of mapping `transform` over `array`.
    ///
    /// If `transform` throws a `JSONError`, the error will be modified to include the index
    /// of the element that caused the error.
    ///
    /// - Parameter array: The `JSONArray` to map over.
    /// - Parameter transform: A block that is called once for each element of `array`.
    /// - Returns: An array with the concatenated results of mapping `transform` over `array`.
    /// - Throws: Rethrows any error thrown by `transform`.
    /// - Complexity: O(*M* + *N*) where *M* is the length of `array` and *N* is the length of the result.
    /// - Bug: This method must be marked as `throws` instead of `rethrows` because of Swift compiler
    ///   limitations. If you want to map an array with a non-throwing transform function, use
    ///   `SequenceType.flatMap` instead.
    static func flatMap<S: SequenceType>(array: JSONArray, @noescape _ transform: JSON throws -> S) throws -> [S.Generator.Element] {
        // FIXME: Use SequenceType.flatMap() once it becomes @noescape
        var results: [S.Generator.Element] = []
        for (i, elt) in array.enumerate() {
            try scoped(i) {
                results.appendContentsOf(try transform(elt))
            }
        }
        return results
    }
}

public extension JSON {
    /// Subscripts the receiver with `key`, converts the value to an array, and returns an `Array`
    /// containing the results of mapping `transform` over the value.
    ///
    /// - Note: This method is equivalent to `getArray(key, { try JSON.map($0, transform) })`.
    ///
    /// - Parameter key: The key to subscript the receiver with.
    /// - Parameter transform: A block that is called once for each element of the resulting array.
    /// - Returns: An array with the results of mapping `transform` over the array.
    /// - Throws: `JSONError` if the receiver is not an object, `key` does not exist, or the value
    ///   is not an array. Also rethrows any error thrown by `transform`.
    /// - Complexity: O(*N*).
    func mapArray<T>(key: Swift.String, @noescape _ transform: JSON throws -> T) throws -> [T] {
        return try getArray(key, { try JSON.map($0, transform) })
    }
    
    /// Subscripts the receiver with `index`, converts the value to an array, and returns an `Array`
    /// containing the results of mapping `transform` over the value.
    ///
    /// - Note: This method is equivalent to `getArray(index, { try JSON.map($0, transform) })`.
    ///
    /// - Parameter index: The index to subscript the receiver with.
    /// - Parameter transform: A block that is called once for each element of the resulting array.
    /// - Returns: An array with the results of mapping `transform` over the array.
    /// - Throws: `JSONError` if the receiver is not an array, `index` is out of bounds, or the
    ///   value is not an array. Also rethrows any error thrown by `transform`.
    /// - Complexity: O(*N*).
    func mapArray<T>(index: Swift.Int, @noescape _ transform: JSON throws -> T) throws -> [T] {
        return try getArray(index, { try JSON.map($0, transform) })
    }
    
    /// Subscripts the receiver with `key`, converts the value to an array, and returns an `Array`
    /// containing the results of mapping `transform` over the value.
    ///
    /// Returns `nil` if `key` doesn't exist or the value is `null`.
    ///
    /// - Note: This method is equivalent to `getArrayOrNil(key, { try JSON.map($0, transform) })`.
    ///
    /// - Parameter key: The key to subscript the receiver with.
    /// - Parameter transform: A block that is called once for each element of the resulting array.
    /// - Returns: An array with the results of mapping `transform` over the array, or `nil` if
    ///   `key` does not exist or the value is `null`.
    /// - Throws: `JSONError` if the receiver is not an object or `key` exists but the value is not
    ///   an array or `null`. Also rethrows any error thrown by `transform`.
    /// - Complexity: O(*N*).
    func mapArrayOrNil<T>(key: Swift.String, @noescape _ transform: JSON throws -> T) throws -> [T]? {
        return try getArrayOrNil(key, { try JSON.map($0, transform) })
    }
    
    /// Subscripts the receiver with `index`, converts the value to an array, and returns an `Array`
    /// containing the results of mapping `transform` over the value.
    ///
    /// Returns `nil` if `index` is out of bounds or the value is `null`.
    ///
    /// - Note: This method is equivalent to `getArrayOrNil(index, { try JSON.map($0, transform) })`.
    ///
    /// - Parameter index: The index to subscript the receiver with.
    /// - Parameter transform: A block that is called once for each element of the resulting array.
    /// - Returns: An array with the results of mapping `transform` over the array, or `nil` if
    ///   `index` is out of bounds or the value is `null`.
    /// - Throws: `JSONError` if the receiver is not an object or the subscript value is not an
    ///   array or `null`. Also rethrows any error thrown by `transform`.
    /// - Complexity: O(*N*).
    func mapArrayOrNil<T>(index: Swift.Int, @noescape _ transform: JSON throws -> T) throws -> [T]? {
        return try getArrayOrNil(index, { try JSON.map($0, transform) })
    }
    
    /// Subscripts the receiver with `key`, converts the value to an array, and returns an `Array`
    /// containing the non-`nil` results of mapping `transform` over the value.
    ///
    /// - Note: This method is equivalent to `getArray(key, { try JSON.flatMap($0, transform) })`.
    ///
    /// - Parameter key: The key to subscript the receiver with.
    /// - Parameter transform: A block that is called once for each element of the resulting array.
    /// - Returns: An array with the non-`nil` results of mapping `transform` over the array.
    /// - Throws: `JSONError` if the receiver is not an object, `key` does not exist, or the value
    ///   is not an array. Also rethrows any error thrown by `transform`.
    /// - Complexity: O(*N*).
    func flatMapArray<T>(key: Swift.String, @noescape _ transform: JSON throws -> T?) throws -> [T] {
        return try getArray(key, { try JSON.flatMap($0, transform) })
    }
    
    /// Subscripts the receiver with `key`, converts the value to an array, and returns an `Array`
    /// containing the concatenated results of mapping `transform` over the value.
    ///
    /// - Note: This method is equivalent to `getArray(key, { try JSON.flatMap($0, transform) })`.
    ///
    /// - Parameter key: The key to subscript the receiver with.
    /// - Parameter transform: A block that is called once for each element of the resulting array.
    /// - Returns: An array with the concatenated results of mapping `transform` over the array.
    /// - Throws: `JSONError` if the receiver is not an object, `key` does not exist, or the value
    ///   is not an array. Also rethrows any error thrown by `transform`.
    /// - Complexity: O(*M* + *N*) where *M* is the length of `array` and *N* is the length of the result.
    func flatMapArray<S: SequenceType>(key: Swift.String, @noescape _ transform: JSON throws -> S) throws -> [S.Generator.Element] {
        return try getArray(key, { try JSON.flatMap($0, transform) })
    }
    
    /// Subscripts the receiver with `index`, converts the value to an array, and returns an `Array`
    /// containing the non-`nil` results of mapping `transform` over the value.
    ///
    /// - Note: This method is equivalent to `getArray(index, { try JSON.flatMap($0, transform) })`.
    ///
    /// - Parameter index: The index to subscript the receiver with.
    /// - Parameter transform: A block that is called once for each element of the resulting array.
    /// - Returns: An array with the non-`nil` results of mapping `transform` over the array.
    /// - Throws: `JSONError` if the receiver is not an array, `index` is out of bounds, or the
    ///   value is not an array. Also rethrows any error thrown by `transform`.
    /// - Complexity: O(*N*).
    func flatMapArray<T>(index: Swift.Int, @noescape _ transform: JSON throws -> T?) throws -> [T] {
        return try getArray(index, { try JSON.flatMap($0, transform) })
    }
    
    /// Subscripts the receiver with `index`, converts the value to an array, and returns an `Array`
    /// containing the concatenated results of mapping `transform` over the value.
    ///
    /// - Note: This method is equivalent to `getArray(index, { try JSON.flatMap($0, transform) })`.
    ///
    /// - Parameter index: The index to subscript the receiver with.
    /// - Parameter transform: A block that is called once for each element of the resulting array.
    /// - Returns: An array with the concatenated results of mapping `transform` over the array.
    /// - Throws: `JSONError` if the receiver is not an array, `index` is out of bounds, or the
    ///   value is not an array. Also rethrows any error thrown by `transform`.
    /// - Complexity: O(*M* + *N*) where *M* is the length of `array` and *N* is the length of the result.
    func flatMapArray<S: SequenceType>(index: Swift.Int, @noescape _ transform: JSON throws -> S) throws -> [S.Generator.Element] {
        return try getArray(index, { try JSON.flatMap($0, transform) })
    }
    
    /// Subscripts the receiver with `key`, converts the value to an array, and returns an `Array`
    /// containing the non-`nil` results of mapping `transform` over the value.
    ///
    /// Returns `nil` if `key` doesn't exist or the value is `null`.
    ///
    /// - Note: This method is equivalent to `getArrayOrNil(key, { try JSON.flatMap($0, transform) })`.
    ///
    /// - Parameter key: The key to subscript the receiver with.
    /// - Parameter transform: A block that is called once for each element of the resulting array.
    /// - Returns: An array with the non-`nil` results of mapping `transform` over the array, or
    ///   `nil` if `key` does not exist or the value is `null`.
    /// - Throws: `JSONError` if the receiver is not an object or the value is not an array or
    ///   `null`. Also rethrows any error thrown by `transform`.
    /// - Complexity: O(*N*).
    func flatMapArrayOrNil<T>(key: Swift.String, @noescape _ transform: JSON throws -> T?) throws -> [T]? {
        return try getArrayOrNil(key, { try JSON.flatMap($0, transform) })
    }
    
    /// Subscripts the receiver with `key`, converts the value to an array, and returns an `Array`
    /// containing the concatenated results of mapping `transform` over the value.
    ///
    /// Returns `nil` if `key` doesn't exist or the value is `null`.
    ///
    /// - Note: This method is equivalent to `getArrayOrNil(key, { try JSON.flatMap($0, transform) })`.
    ///
    /// - Parameter key: The key to subscript the receiver with.
    /// - Parameter transform: A block that is called once for each element of the resulting array.
    /// - Returns: An array with the concatenated results of mapping `transform` over the array,
    ///   or `nil` if `key` does not exist or the value is `null`.
    /// - Throws: `JSONError` if the receiver is not an object or the value is not an array or
    ///   `null`. Also rethrows any error thrown by `transform`.
    /// - Complexity: O(*M* + *N*) where *M* is the length of `array` and *N* is the length of the result.
    func flatMapArrayOrNil<S: SequenceType>(key: Swift.String, @noescape _ transform: JSON throws -> S) throws -> [S.Generator.Element]? {
        return try getArrayOrNil(key, { try JSON.flatMap($0, transform) })
    }
    
    /// Subscripts the receiver with `index`, converts the value to an array, and returns an `Array`
    /// containing the non-`nil` results of mapping `transform` over the value.
    ///
    /// Returns `nil` if `index` is out of bounds or the value is `null`.
    ///
    /// - Note: This method is equivalent to `getArrayOrNil(index, { try JSON.flatMap($0, transform) })`.
    ///
    /// - Parameter index: The index to subscript the receiver with.
    /// - Parameter transform: A block that is called once for each element of the resulting array.
    /// - Returns: An array with the non-`nil` results of mapping `transform` over the array, or
    ///   `nil` if `index` is out of bounds or the value is `null`.
    /// - Throws: `JSONError` if the receiver is not an array or the value is not an array or
    ///   `null`. Also rethrows any error thrown by `transform`.
    /// - Complexity: O(*N*).
    func flatMapArrayOrNil<T>(index: Swift.Int, @noescape _ transform: JSON throws -> T?) throws -> [T]? {
        return try getArrayOrNil(index, { try JSON.flatMap($0, transform) })
    }
    
    /// Subscripts the receiver with `index`, converts the value to an array, and returns an `Array`
    /// containing the concatenated results of mapping `transform` over the value.
    ///
    /// Returns `nil` if `index` is out of bounds or the value is `null`.
    ///
    /// - Note: This method is equivalent to `getArrayOrNil(index, { try JSON.flatMap($0, transform) })`.
    ///
    /// - Parameter index: The index to subscript the receiver with.
    /// - Parameter transform: A block that is called once for each element of the resulting array.
    /// - Returns: An array with the concatenated results of mapping `transform` over the array,
    ///   or `nil` if `index` is out of bounds or the value is `null`.
    /// - Throws: `JSONError` if the receiver is not an array or the value is not an array or
    ///   `null`. Also rethrows any error thrown by `transform`.
    /// - Complexity: O(*M* + *N*) where *M* is the length of `array` and *N* is the length of the result.
    func flatMapArrayOrNil<S: SequenceType>(index: Swift.Int, @noescape _ transform: JSON throws -> S) throws -> [S.Generator.Element]? {
        return try getArrayOrNil(index, { try JSON.flatMap($0, transform) })
    }
}

public extension JSONObject {
    /// Subscripts the receiver with `key`, converts the value to an array, and returns an `Array`
    /// containing the results of mapping `transform` over the value.
    ///
    /// - Note: This method is equivalent to `getArray(key, { try JSON.map($0, transform) })`.
    ///
    /// - Parameter key: The key to subscript the receiver with.
    /// - Parameter transform: A block that is called once for each element of the resulting array.
    /// - Returns: An array with the results of mapping `transform` over the array.
    /// - Throws: `JSONError` if `key` does not exist or the value is not an array.
    ///   Also rethrows any error thrown by `transform`.
    /// - Complexity: O(*N*).
    func mapArray<T>(key: Swift.String, @noescape _ transform: JSON throws -> T) throws -> [T] {
        return try getArray(key, { try JSON.map($0, transform) })
    }
    
    /// Subscripts the receiver with `key`, converts the value to an array, and returns an `Array`
    /// containing the results of mapping `transform` over the value.
    ///
    /// Returns `nil` if `key` doesn't exist or the value is `null`.
    ///
    /// - Note: This method is equivalent to `getArrayOrNil(key, { try JSON.map($0, transform) })`.
    ///
    /// - Parameter key: The key to subscript the receiver with.
    /// - Parameter transform: A block that is called once for each element of the resulting array.
    /// - Returns: An array with the results of mapping `transform` over the array, or `nil` if
    ///   `key` does not exist or the value is `null`.
    /// - Throws: `JSONError` if `key` exists but the value is not an array or `null`.
    ///   Also rethrows any error thrown by `transform`.
    /// - Complexity: O(*N*).
    func mapArrayOrNil<T>(key: Swift.String, @noescape _ transform: JSON throws -> T) throws -> [T]? {
        return try getArrayOrNil(key, { try JSON.map($0, transform) })
    }
    
    /// Subscripts the receiver with `key`, converts the value to an array, and returns an `Array`
    /// containing the non-`nil` results of mapping `transform` over the value.
    ///
    /// - Note: This method is equivalent to `getArray(key, { try JSON.flatMap($0, transform) })`.
    ///
    /// - Parameter key: The key to subscript the receiver with.
    /// - Parameter transform: A block that is called once for each element of the resulting array.
    /// - Returns: An array with the non-`nil` results of mapping `transform` over the array.
    /// - Throws: `JSONError` if `key` does not exist or the value is not an array.
    ///   Also rethrows any error thrown by `transform`.
    /// - Complexity: O(*N*).
    func flatMapArray<T>(key: Swift.String, @noescape _ transform: JSON throws -> T?) throws -> [T] {
        return try getArray(key, { try JSON.flatMap($0, transform) })
    }
    
    /// Subscripts the receiver with `key`, converts the value to an array, and returns an `Array`
    /// containing the concatenated results of mapping `transform` over the value.
    ///
    /// - Note: This method is equivalent to `getArray(key, { try JSON.flatMap($0, transform) })`.
    ///
    /// - Parameter key: The key to subscript the receiver with.
    /// - Parameter transform: A block that is called once for each element of the resulting array.
    /// - Returns: An array with the concatenated results of mapping `transform` over the array.
    /// - Throws: `JSONError` if `key` does not exist or the value is not an array.
    ///   Also rethrows any error thrown by `transform`.
    /// - Complexity: O(*M* + *N*) where *M* is the length of `array` and *N* is the length of the result.
    func flatMapArray<S: SequenceType>(key: Swift.String, @noescape _ transform: JSON throws -> S) throws -> [S.Generator.Element] {
        return try getArray(key, { try JSON.flatMap($0, transform) })
    }
    
    /// Subscripts the receiver with `key`, converts the value to an array, and returns an `Array`
    /// containing the non-`nil` results of mapping `transform` over the value.
    ///
    /// Returns `nil` if `key` doesn't exist or the value is `null`.
    ///
    /// - Note: This method is equivalent to `getArrayOrNil(key, { try JSON.flatMap($0, transform) })`.
    ///
    /// - Parameter key: The key to subscript the receiver with.
    /// - Parameter transform: A block that is called once for each element of the resulting array.
    /// - Returns: An array with the non-`nil` results of mapping `transform` over the array, or
    ///   `nil` if `key` does not exist or the value is `null`.
    /// - Throws: `JSONError` if `key` exists but the value is not an array or `null`.
    ///   Also rethrows any error thrown by `transform`.
    /// - Complexity: O(*N*).
    func flatMapArrayOrNil<T>(key: Swift.String, @noescape _ transform: JSON throws -> T?) throws -> [T]? {
        return try getArrayOrNil(key, { try JSON.flatMap($0, transform) })
    }
    
    /// Subscripts the receiver with `key`, converts the value to an array, and returns an `Array`
    /// containing the concatenated results of mapping `transform` over the value.
    ///
    /// Returns `nil` if `key` doesn't exist or the value is `null`.
    ///
    /// - Note: This method is equivalent to `getArrayOrNil(key, { try JSON.flatMap($0, transform) })`.
    ///
    /// - Parameter key: The key to subscript the receiver with.
    /// - Parameter transform: A block that is called once for each element of the resulting array.
    /// - Returns: An array with the concatenated results of mapping `transform` over the array,
    ///   or `nil` if `key` does not exist or the value is `null`.
    /// - Throws: `JSONError` if `key` exists but the value is not an array or `null`.
    ///   Also rethrows any error thrown by `transform`.
    /// - Complexity: O(*M* + *N*) where *M* is the length of `array` and *N* is the length of the result.
    func flatMapArrayOrNil<S: SequenceType>(key: Swift.String, @noescape _ transform: JSON throws -> S) throws -> [S.Generator.Element]? {
        return try getArrayOrNil(key, { try JSON.flatMap($0, transform) })
    }
}

// MARK: -

internal func getRequired(dict: JSONObject, key: String, type: JSONError.JSONType) throws -> JSON {
    guard let value = dict[key] else { throw JSONError.MissingOrInvalidType(path: key, expected: .Required(type), actual: nil) }
    return value
}

internal func getRequired(ary: JSONArray, index: Int, type: JSONError.JSONType) throws -> JSON {
    guard let value = ary[safe: index] else { throw JSONError.MissingOrInvalidType(path: "[\(index)]", expected: .Required(type), actual: nil) }
    return value
}

@inline(__always)
internal func scoped<T>(key: String, @noescape f: () throws -> T) throws -> T {
    do {
        return try f()
    } catch let error as JSONError {
        throw error.withPrefix(key)
    }
}

@inline(__always)
internal func scoped<T>(index: Int, @noescape f: () throws -> T) throws -> T {
    do {
        return try f()
    } catch let error as JSONError {
        throw error.withPrefix("[\(index)]")
    }
}

internal extension ContiguousArray {
    subscript(safe index: Int) -> Element? {
        guard index >= startIndex && index < endIndex else { return nil }
        return self[index]
    }
}

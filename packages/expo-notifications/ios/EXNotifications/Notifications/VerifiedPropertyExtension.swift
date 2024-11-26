import ExpoModulesCore

public extension [AnyHashable: Any] {
  func verifiedProperty<T>(_ key: String, type: T.Type) throws -> T? {
    let request = self
    if request[key] == nil {
      return nil
    }
    guard let value = request[key] as? T else {
      let exceptionName = "Value under key \(key) is not a valid \(type)"
      throw Exception(name: exceptionName, description: "")
    }
    return value
  }
}

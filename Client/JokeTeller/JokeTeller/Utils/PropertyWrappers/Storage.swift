import Foundation

@propertyWrapper
struct Stroge<T: Codable> {
    // MARK: - Properties
    private let key: StorageKeys
    private let defaultValue: T
    // MARK: - Init
    init(key: StorageKeys, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.object(forKey: key.rawValue) as? Data else {
                return defaultValue
            }
            let decodedValue = try? JSONDecoder().decode(T.self, from: data)
            return decodedValue ?? defaultValue
        }
        set {
            let decodedValue = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(decodedValue, forKey: key.rawValue)
        }
    }
}
// MARK: - ExpressByNil Extension
extension Stroge where T: ExpressibleByNilLiteral {
    init(key: StorageKeys) {
        self.init(key: key, defaultValue: nil)
    }
}
// MARK: - StorageKeys
enum StorageKeys: String {
    case webscoketUrlString
}

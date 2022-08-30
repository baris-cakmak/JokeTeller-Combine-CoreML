import Foundation

extension URL {
    static func string(_ string: String) -> Self {
        guard let url = URL.init(string: string) else {
            fatalError("Url from string is failed")
        }
        return url
    }
}

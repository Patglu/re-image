import UIKit

let fileName = ""

extension FileManager {
    static var docDirectoryURL: URL {
        return Self.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func documentExist(name docName: String) -> Bool {
        fileExists(atPath: Self.docDirectoryURL.appendingPathComponent(docName).path)
    }
}

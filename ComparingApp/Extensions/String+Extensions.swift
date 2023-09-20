
import Foundation
import UIKit

extension String {
    func toUIImage() -> UIImage? {
        if let jsonData = self.data(using: .utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: String],
                   let base64String = json["imageData"],
                   let imageData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) {
                    return UIImage(data: imageData)
                }
            } catch {
                print("Error converting JSON to UIImage: \(error)")
            }
        }
        
        return nil
    }
    
    
    
    func hexToUIColor() -> UIColor? {
        var hexSanitized = self.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    
}

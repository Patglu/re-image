import UIKit
import CoreVideo
import CoreImage
import SwiftUI


extension UIImage {
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        return pixelBuffer
    }
    
    static func fromPixelBuffer(_ pixelBuffer: CVPixelBuffer) -> UIImage? {
        // Lock the pixel buffer to access its data
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
        
        // Get the pixel buffer's base address
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        
        // Get the width, height, and bytes per row of the pixel buffer
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        
        // Create a color space for grayscale
        let colorSpace = CGColorSpaceCreateDeviceGray()
        
        // Create a Core Graphics context
        guard let context = CGContext(data: baseAddress,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue).rawValue) else {
            return nil
        }
        
        // Create a CGImage from the context
        guard let cgImage = context.makeImage() else {
            return nil
        }
        
        // Create a UIImage from the CGImage
        let image = UIImage(cgImage: cgImage)
        
        // Unlock the pixel buffer
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
        
        return image
    }
}


extension UIImage{
    func scale(newWidth: CGFloat, newHeight: CGFloat) -> UIImage
    {
        guard self.size.width != newWidth else{return self}
        
//        let scaleFactor = newWidth / self.size.width
        
//        let newHeight = self.size.height * scaleFactor
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        return newImage ?? self
    }
}


extension UIImage {
    func removeWhiteBackground() -> UIImage? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        // Create a bitmap context with a transparent background
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        
        // Draw the image with alpha mask onto the transparent background
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Create a new CGImage from the context
        guard let newCGImage = context.makeImage() else {
            return nil
        }
        
        // Create a UIImage from the new CGImage
        let newImage = UIImage(cgImage: newCGImage)
        
        return newImage
    }
    
    func saveAsPNG(to url: URL) -> Bool {
        guard let data = self.pngData() else {
            return false
        }
        
        do {
            try data.write(to: url)
            return true
        } catch {
            return false
        }
    }
}



extension UIImage {
    func dominantColors(k: Int) -> [UIColor]? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        let context = CIContext(options: [.workingColorSpace: kCFNull])
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }

        let uiImage = UIImage(cgImage: cgImage)

        // Use the k-means algorithm or another color clustering method to find the dominant colors
        if let dominantColors = uiImage.kMeansClusters(k: k) {
            return dominantColors
        }
        
        return nil
    }
}

extension UIImage {
    func kMeansClusters(k: Int) -> [UIColor]? {
        guard let cgImage = self.cgImage else { return nil }
        
        let pixelData = cgImage.pixelData()
        
        // Use a color clustering algorithm here to find dominant colors
        // For simplicity, let's assume you have a function that performs k-means clustering
        
        // Replace the following line with your clustering algorithm's result
        let dominantColors: [UIColor] = []
        
        return dominantColors
    }
}

extension CGImage {
    func pixelData() -> [Pixel] {
        guard let data = self.dataProvider?.data,
              let pointer = CFDataGetBytePtr(data) else {
            return []
        }
        
        let bytesPerPixel = 4
        let width = self.width
        let height = self.height
        var pixels: [Pixel] = []
        
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * bytesPerPixel
                let alpha = CGFloat(pointer[offset + 3]) / 255.0
                let red = CGFloat(pointer[offset]) / 255.0
                let green = CGFloat(pointer[offset + 1]) / 255.0
                let blue = CGFloat(pointer[offset + 2]) / 255.0
                pixels.append(Pixel(red: red, green: green, blue: blue, alpha: alpha))
            }
        }
        
        return pixels
    }
}

struct Pixel {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat
}

extension UIImage {
    func toJSONString() -> String? {
        if let imageData = self.jpegData(compressionQuality: 1.0) {
            let base64String = imageData.base64EncodedString(options: .lineLength64Characters)
            let json = ["imageData": base64String]
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    return jsonString
                }
            } catch {
                print("Error converting UIImage to JSON: \(error)")
            }
        }
        
        return nil
    }
}




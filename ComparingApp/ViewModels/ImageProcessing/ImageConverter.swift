import UIKit
import ColorThiefSwift

final class ImageConverter {

    func createPNGImage(
        origionalImage: UIImage?,
        alphaMask: UIImage?,
        completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard var originalImage = origionalImage,
              let alphaImage = alphaMask else {
            completion(.failure(NSError(domain: "InvalidInput", code: 0, userInfo: nil))) // You can customize the error here.
            return
        }

        originalImage = resizeImage(originalImage, newSize: alphaImage.size)

        guard let originalCIImage = CIImage(image: originalImage),
              let alphaCIImage = CIImage(image: alphaImage) else {
            completion(.failure(NSError(domain: "ImageCreationError", code: 1, userInfo: nil))) // Customize error
            return
        }

        let filter = CIFilter(name: "CIBlendWithMask")
        filter?.setValue(originalCIImage, forKey: kCIInputImageKey)
        filter?.setValue(alphaCIImage, forKey: kCIInputMaskImageKey)

        guard let maskedCIImage = filter?.outputImage else {
            completion(.failure(NSError(domain: "FilterError", code: 2, userInfo: nil))) // Customize error
            return
        }

        let context = CIContext(options: nil)

        guard let cgImage = context.createCGImage(maskedCIImage, from: alphaCIImage.extent) else {
            completion(.failure(NSError(domain: "CGImageCreationError", code: 3, userInfo: nil))) // Customize error
            return
        }

        let uiImage = UIImage(cgImage: cgImage)

        if let data = uiImage.pngData(),
            let safeImage = UIImage(data: data) {
            completion(.success(safeImage))
        } else {
            completion(.failure(NSError(domain: "UIImageCreationError", code: 4, userInfo: nil))) // Customize error
        }
    }

    
    func createColorPalette(inputImage: UIImage, completion: @escaping ([String]) -> Void){
        var colorsFromImage = [String]()
        
        guard let colours = ColorThief.getPalette(from: inputImage, colorCount: 3,quality: 1) else {return}
            for i in 0 ..< 4 {
            if i < colours.count {
                let color = colours[i]
                colorsFromImage.append(color.makeUIColor().hexString())
                completion(colorsFromImage)
            } else {
                completion([])
                print("Unable to get color from image")
            }
        }
    }
    
    private func resizeImage(_ image: UIImage, newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? image
    }
}

enum ConverstionError: Error {
    case badImage
}

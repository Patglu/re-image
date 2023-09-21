import Foundation
import UIKit
import CoreML

class ClothingPredictor {
    private let imageSegmentor: clothSegmentation
    private let clothingClassifier: Resnet50
    private let secondClothingClassifier: efficientnetv2s
    private let vitClassifier: MobileViT_fp16
    private let imageConverter = ImageConverter()
    
    init() throws {
        imageSegmentor = try clothSegmentation(configuration: MLModelConfiguration())
        clothingClassifier = try Resnet50(configuration: MLModelConfiguration())
        secondClothingClassifier = try efficientnetv2s(configuration: MLModelConfiguration())
        vitClassifier = try MobileViT_fp16()
    }
    
    func predictClothingItem(
        image: UIImage,
        completion: @escaping ([String]) -> Void) {
            
        var imageDescriptors = [String]()
        var chosenImage = image.scale(newWidth: 640, newHeight: 960)
            
        guard let pixelBuffer = chosenImage.toCVPixelBuffer() else { return }
        do {
            let result = try imageSegmentor.prediction(input: clothSegmentationInput(x_1With: chosenImage.cgImage!))
            let pixelBuffer = result.activation_out
            let alphaMask = UIImage.fromPixelBuffer(pixelBuffer)
            
            imageConverter.createPNGImage(origionalImage: image, alphaMask: alphaMask) { result in
                switch result {
                case .success(let pngImage):
                    if let chosenCgImage = pngImage.cgImage {
                        do {
                            let results = try self.clothingClassifier.prediction(input: Resnet50Input(imageWith: chosenCgImage))
                            let effResults = try self.secondClothingClassifier.prediction(input: efficientnetv2sInput(keras_layer_1_inputWith: chosenCgImage))
                            let vitResults = try self.vitClassifier.prediction(input: MobileViT_fp16Input(imageWith: chosenCgImage))
                            
                            imageDescriptors.append(contentsOf: results.classLabel.components(separatedBy: ","))
                            imageDescriptors.append(contentsOf: vitResults.classLabel.components(separatedBy: ","))
                            imageDescriptors.append(contentsOf: effResults.classLabel.components(separatedBy: ","))
                            
                            let setOfDescriptors = Set(imageDescriptors)
                            imageDescriptors = Array(setOfDescriptors)
                            completion(imageDescriptors)
                        } catch {
                            print("Could not fetch data from model: \(error)")
                            completion([])
                        }
                    }
                case .failure(let failure):
                    print(failure)
                    completion([])
                }
            }
            
        } catch {
            print("Could not fetch data from model: \(error)")
            completion([])
        }
    }

    
    
    //    func predictClothingFromURL(urlString: String, completion: @escaping (UIImage?) -> Void) {
    //        ImageDownloader.downloadImage(from: urlString) { image in
    //            guard let image = image else {
    //                completion(nil)
    //                return
    //            }
    //
    //
    //            completion(UIImage())
    //        }
    //    }
}

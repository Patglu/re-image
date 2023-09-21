import SwiftUI
import CoreML
import CoreImage
import SwiftSoup
import ColorThiefSwift

class ComparingClothesViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var image: UIImage?
    @Published var outputImage: UIImage?
    @Published var finalOutputImage: UIImage?
    
    @Published var showPicker: Bool = false
    @Published var source: SourcePicker.Source = .library
    @Published var imageDescritptors = [String]()
    @Published var imagesFromURL = [UIImage]()
    @Published var selectedURLImage: UIImage?
    @Published var colorsFromImage = [UIColor]()
    
    
    private var classLabel: String = ""
    private var imageClassifier: ClothesIdentifier?
    private var imageSegmentor: clothSegmentation?
    private var clothingClassifier: Resnet50?
    private var secondClothingClassifier: efficientnetv2s?
    private var vitClassifier: MobileViT_fp16?
    
    var document: Document = Document.init("")
    var imageURLs = Set<String>()
    
    
    init() {
        do {
            imageClassifier = try ClothesIdentifier(configuration: MLModelConfiguration())
            imageSegmentor = try clothSegmentation(configuration: MLModelConfiguration())
            clothingClassifier = try Resnet50(configuration: MLModelConfiguration())
            secondClothingClassifier = try efficientnetv2s(configuration: MLModelConfiguration())
            vitClassifier = try MobileViT_fp16()
        } catch {
            print("Error intialising Model: \(error)")
        }
    }
    
    //MARK: Use Combine to replace to comletion block
    func setup(){
        
    }
    
    func showPhotoPicker() {
        if source == .camera {
            if !SourcePicker.checkPermissions() {
                print("There is no camera on this device")
                return
            }
        }
        
        showPicker = true
    }
    
    
    func predictClothingItem( completion: @escaping () -> Void) {
           isLoading = true
           guard var chosenImage = image else { return }
           chosenImage = chosenImage.scale(newWidth: 640, newHeight: 960)
            guard chosenImage.toCVPixelBuffer() != nil   else { return }
        
           classLabel = ""
           do {
               let result  = try imageSegmentor?.prediction(input: clothSegmentationInput(x_1With: chosenImage.cgImage!))
               
               if let pixelBuffer: CVPixelBuffer = result?.activation_out{
                   let image = UIImage.fromPixelBuffer(pixelBuffer)
                   outputImage = image
                   createClippedImage()
                   createAndSavePNG()
               }
               
               if let chosenCgImage = finalOutputImage?.cgImage {
                   let results =  try clothingClassifier?.prediction(input: Resnet50Input(imageWith: chosenCgImage))
                   let effResulst  = try secondClothingClassifier?.prediction(input: efficientnetv2sInput(keras_layer_1_inputWith: chosenCgImage))
                   let vitResults = try vitClassifier?.prediction(input: MobileViT_fp16Input(imageWith: chosenCgImage))
                   
                   

                   imageDescritptors.append(contentsOf:  results?.classLabel.components(separatedBy: ",") ?? [])
                   imageDescritptors.append(contentsOf:  vitResults?.classLabel.components(separatedBy: ",") ?? [])
                   imageDescritptors.append(contentsOf:  effResulst?.classLabel.components(separatedBy: ",") ?? [])
                   
                   var setOfDescriptors = Set<String>()
                   setOfDescriptors = Set(imageDescritptors)
                   imageDescritptors = Array(setOfDescriptors)
                   completion()
               }
               
           } catch {
               print("Could not fetch data from model: \(error)")
           }
       }
    
    
    func predictClothingURL(urlString: String, compleiton: @escaping () -> Void){
        
        downloadImage(urlString: urlString){ [weak self] downloadedImage in
            
            do {
                let segmentedClothing = try self?.imageSegmentor?.prediction(input: clothSegmentationInput(x_1With: downloadedImage.cgImage!))
                
                if let pixelBuffer: CVPixelBuffer = segmentedClothing?.activation_out{
                    let image = UIImage.fromPixelBuffer(pixelBuffer)
                    self?.outputImage = image
                    self?.createClippedImage()
                    self?.createAndSavePNG()
                }
                
                if let chosenCgImage =   self?.finalOutputImage?.cgImage {
                    let results =  try   self?.clothingClassifier?.prediction(input: Resnet50Input(imageWith: chosenCgImage))
                    let effResulst  = try   self?.secondClothingClassifier?.prediction(input: efficientnetv2sInput(keras_layer_1_inputWith: chosenCgImage))
                    let vitResults = try   self?.vitClassifier?.prediction(input: MobileViT_fp16Input(imageWith: chosenCgImage))
                    
                    self?.imageDescritptors.append(contentsOf:  results?.classLabel.components(separatedBy: ",") ?? [])
                    self?.imageDescritptors.append(contentsOf:  vitResults?.classLabel.components(separatedBy: ",") ?? [])
                    self?.imageDescritptors.append(contentsOf:  effResulst?.classLabel.components(separatedBy: ",") ?? [])
                    
                    var setOfDescriptors = Set<String>()
                    setOfDescriptors = Set(self?.imageDescritptors ?? [])
                    self?.imageDescritptors = Array(setOfDescriptors)
                }
                compleiton()
                
            } catch {
                
                print("Could not fetch data from model: \(error)")
                
            }
        }
    }
    
    func getImagesFromURL(urlString: String){
        isLoading = true
        imagesFromURL = []
        self.downloadHTML(urlString: urlString) {
            self.isLoading = false
        }
        
    }
    
    
    private func downloadImage(urlString: String,onResult: @escaping (UIImage) -> Void){
        let url = URL(string: urlString)!
        
        let dataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, _, _) in
            if let data = data {
                DispatchQueue.main.async {
                    self?.image = UIImage(data: data)
                    onResult(UIImage(data: data) ?? UIImage())
                }
                
            }
        }
        dataTask.resume()
    }
    
    private func createClippedImage() {
        /*
         Steps to take:
         1. Resize the original image to match the size of the alpha mask
         2. Create CIImages from input images
         3. Create a filter to blend the images with the mask
         4. Apply the mask
         5. Use the extent of the alpha mask to create the CGImage
         6. (Optional) Save the output as a PNG
         */
        
        guard var originalImage = image,
              let alphaImage = outputImage else {
            return
        }
        
        
        originalImage = resizeImage(originalImage, newSize: alphaImage.size)
        
        
        guard let originalCIImage = CIImage(image: originalImage),
              let alphaCIImage = CIImage(image: alphaImage) else {
            print("Error: Unable to create CIImage from input images.")
            return
        }
        
        
        let filter = CIFilter(name: "CIBlendWithMask")
        filter?.setValue(originalCIImage, forKey: kCIInputImageKey)
        filter?.setValue(alphaCIImage, forKey: kCIInputMaskImageKey)
        
        
        guard let maskedCIImage = filter?.outputImage else {
            print("Error: Unable to apply masking filter.")
            return
        }
        
        let context = CIContext(options: nil)
        
        
        guard let cgImage = context.createCGImage(maskedCIImage, from: alphaCIImage.extent) else {
            print("Error: Unable to create CGImage from CIImage.")
            return
        }
        
        let uiImage = UIImage(cgImage: cgImage)
        
        
        if let data = uiImage.pngData() {
            finalOutputImage = UIImage(data: data)
            saveToDevice(inputImage: finalOutputImage ?? UIImage())
            guard let colours = ColorThief.getPalette(from: uiImage, colorCount: 3,quality: 1) else {return}
                for i in 0 ..< 4 {
                if i < colours.count {
                    let color = colours[i]
                    colorsFromImage.append(color.makeUIColor())
//                    print(color.makeUIColor().hexString())
                } else {
                    print("Unable to get color from image")
                }
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
    
    private func createAndSavePNG() {
        guard let alphaImage = outputImage,
              let pngData = alphaImage.removeWhiteBackground()?.pngData(),
              let transparentImage = UIImage(data: pngData) else { return }
        
    }
    
    private func saveToDevice(inputImage: UIImage) {
        let imageSaver = ImageSaver()
//        imageSaver.writeToPhotoAlbum(image: inputImage)
        finalOutputImage = inputImage
        isLoading = false
    }
    
    private func downloadHTML(urlString: String, onResult: @escaping () -> Void) {
        guard let url = URL(string: urlString) else {
            print("Doesn't seem to be a valid URL")
            return
        }
        
        // Perform the network operation asynchronously
        DispatchQueue.global(qos: .background).async {
            do {
                let html = try String(contentsOf: url)
                
                // Parse it into a Document
                let document = try SwiftSoup.parse(html)
                
                // Update UI elements on the main queue
                DispatchQueue.main.async {
                    self.document = document
                    
                    for element in try! document.select("img").array() {
                        if let src = try? element.attr("src"), !src.contains(".svg"), !src.contains(".png") {
                            self.imageURLs.insert(src)
                        }
                    }
                    
                    
                    for image in self.imageURLs {
                        self.downloadImage(urlString: image) { [weak self] downloadedImage in
                            self?.imagesFromURL.append(downloadedImage)
                        }
                    }
                    
                    onResult()
                }
            } catch let error {
                // Handle errors appropriately (e.g., show an error message)
                DispatchQueue.main.async {
                    print("Error: \(error)")
                }
            }
        }
    }

}

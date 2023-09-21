import UIKit

// MARK: - ImageDownloader
class ImageDownloader {
    
    static func downloadImage(from urlString: String, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(ImageDownloadError.invalidURL))
            return
        }

        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 15) // 15 seconds

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let image = UIImage(data: data) {
                completion(.success(image))
            } else {
                completion(.failure(ImageDownloadError.unknownError))
            }
        }.resume()
    }
}

enum ImageDownloadError: Error {
    case invalidURL
    case timeout
    case unknownError
}

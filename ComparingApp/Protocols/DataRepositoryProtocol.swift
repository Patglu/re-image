import Foundation
import Combine

protocol DataRepository {
    associatedtype T: Codable
    
    func addDocument(_ data: T) -> AnyPublisher<Void, Error>
    func getDocuments() -> AnyPublisher<[T], Error>
    func updateDocument(_ data: T, completion: @escaping () -> Void) -> AnyPublisher<Void, Error> 
    func deleteDocument(_ data: T) -> AnyPublisher<Void, Error>
}

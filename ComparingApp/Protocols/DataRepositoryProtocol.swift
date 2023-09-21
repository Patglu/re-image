import Foundation
import Combine


protocol RealmRepository {
    associatedtype T: Codable
    
    func add(_ object: T) -> AnyPublisher<Void, Error>
    func get(_ objectType: T.Type) -> AnyPublisher<[T], Error>
    func update(id: String, newTitle: String, with block: @escaping () -> Void) -> AnyPublisher<Void, Error>
    func delete(_ id: String) -> AnyPublisher<Void, Error>
}

protocol FireStoreRepository {
    associatedtype T: Codable
    func addDocument(collection: String, data: T) -> AnyPublisher<Void, Error>
    func getDocuments(collection: String) -> AnyPublisher<[T], Error>
    func updateDocument(collection: String, documentID: String, data: T) -> AnyPublisher<Void, Error>
    func deleteDocument(collection: String, documentID: String) -> AnyPublisher<Void, Error>
}

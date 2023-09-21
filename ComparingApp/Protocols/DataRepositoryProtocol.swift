import Foundation
import Combine

protocol DataRepository {
    
}

protocol RealmRepository {
    associatedtype T: Codable
    func add(_ object: T) -> AnyPublisher<Void, Error>
    func get(_ objectType: T.Type) -> AnyPublisher<[T], Error>
    func update(id: String, newTitle: String, with block: @escaping () -> Void) -> AnyPublisher<Void, Error>
    func delete(_ id: String) -> AnyPublisher<Void, Error>
}

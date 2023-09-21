import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class FirestoreService: ObservableObject, FireStoreRepository {
    typealias T = Clothingitem
    
    
    private let db = Firestore.firestore()
    private var cancellables: Set<AnyCancellable> = []
    
    
    func addDocument<T: Codable>(collection: String, data: T) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            do {
                let _ = try self.db.collection(collection).addDocument(from: data) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func getDocuments<T: Codable>(collection: String) -> AnyPublisher<[T], Error> {
        return Future<[T], Error> { promise in
            self.db.collection(collection).getDocuments { snapshot, error in
                if let error = error {
                    promise(.failure(error))
                } else if let snapshot = snapshot {
                    do {
                        let items = try snapshot.documents.compactMap {
                            try $0.data(as: T.self)
                        }
                        promise(.success(items))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func updateDocument<T: Codable>(collection: String, documentID: String, data: T) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            do {
                try self.db.collection(collection).document(documentID).setData(from: data) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteDocument(collection: String, documentID: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            self.db.collection(collection).document(documentID).delete { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
}

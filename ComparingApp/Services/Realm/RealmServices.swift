import RealmSwift
import Combine

class RealmService: ObservableObject {
    private var realm: Realm
    
    init() {
        do {
            self.realm = try Realm()
        } catch {
            fatalError("Error initializing Realm: \(error)")
        }
    }
    
    func add<T: Object>(_ object: T) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            do {
                try self.realm.write {
                    self.realm.add(object)
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func get<T: Object>(_ objectType: T.Type) -> AnyPublisher<[T], Error> {
        return Future<[T], Error> { promise in
            let results = self.realm.objects(objectType)
            let objects = Array(results)
            promise(.success(objects))
        }.eraseToAnyPublisher()
    }
    
    func update(id: String,newTitle: String, with block: @escaping () -> Void) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            do {
                let objectId = try ObjectId(string: id)
                let clothing = self.realm.object(ofType: Clothingitem.self, forPrimaryKey: objectId)
                try self.realm.write {
                    clothing?.itemDescription = newTitle
                    block()
                }
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    //    do {
    //        let realm = try Realm()
    //        let objectId = try ObjectId(string: item.id.stringValue)
    //        let clothing = realm.object(ofType: Clothingitem.self, forPrimaryKey: objectId)
    //        try realm.write {
    //            clothing?.itemDescription = newTitle
    //            block()
    //        }
    //    } catch let error {
    //        print(error.localizedDescription)
    //    }
    //
    func delete(_ id: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            do {
                let objectId = try ObjectId(string: id)
                if let clothing = self.realm.object(ofType: Clothingitem.self, forPrimaryKey: objectId) {
                    try self.realm.write {
                        self.realm.delete(clothing)
                    }
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    
    
}

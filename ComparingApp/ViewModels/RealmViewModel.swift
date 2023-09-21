import SwiftUI
import RealmSwift
import Combine

class RealmViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var clothes: [Clothingitem] = []
    private var token: NotificationToken?
    
    private let realmService = RealmService() 
    
    init() {
        fetchObjects()
        setupObserver()
    }
    deinit {
        token?.invalidate()
    }
    
    func fetchObjects() {
        realmService.get(Clothingitem.self)
            .sink(receiveCompletion: { _ in }) { [weak self] objects in
                self?.clothes = objects
            }
            .store(in: &cancellables)
    }
        
    func updateTitle(_ item: Clothingitem, newTitle: String, with block: @escaping () -> Void) {
        realmService.update(id: item.id.stringValue, newTitle: newTitle) {
            block()
        }
        .sink(receiveCompletion: { _ in }) { [weak self] _ in
            self?.fetchObjects()
        }
        .store(in: &cancellables)
    }
    
    func remove(id: String) {
        realmService.delete(id)
            .sink(receiveCompletion: { _ in }) { _ in
                
            }
            .store(in: &cancellables)
    }

    private func setupObserver() {
        do {
            let realm = try Realm()
            let results = realm.objects(Clothingitem.self)
            token = results.observe({ [weak self] changes in
                self?.clothes = results.map(Clothingitem.init)
            })
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

import Combine

class ClothingItemViewModel: ObservableObject {
    private let firestoreService = FirestoreService() // Your Firestore service instance

    @Published var tasks: [Clothingitem] = []

    private var cancellables: Set<AnyCancellable> = []

    func loadTasks() {
        firestoreService.getDocuments(collection: "UserFeedback")
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error loading tasks: \(error.localizedDescription)")
                }
            }, receiveValue: { tasks in
                self.tasks = tasks
            })
            .store(in: &cancellables)
    }

     func addItem(newItem: Clothingitem) {
        let newItem = newItem
        firestoreService.addDocument(collection: "UserFeedback", data: newItem)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error adding task: \(error.localizedDescription)")
                }
            }, receiveValue: { _ in
                self.loadTasks() // Reload the tasks after adding
            })
            .store(in: &cancellables)
    }

    func updateTask(newItem: Clothingitem) {
        firestoreService.updateDocument(collection: "UserFeedback", documentID: newItem.id.stringValue, data: newItem)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error updating task: \(error.localizedDescription)")
                }
            }, receiveValue: { _ in
                self.loadTasks() // Reload the tasks after updating
            })
            .store(in: &cancellables)
    }

    func deleteTask(newItem: Clothingitem) {
        firestoreService.deleteDocument(collection: "UserFeedback", documentID: newItem.id.stringValue)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error deleting task: \(error.localizedDescription)")
                }
            }, receiveValue: { _ in
                self.loadTasks() // Reload the tasks after deleting
            })
            .store(in: &cancellables)
    }
}

import Combine

class ClothingItemViewModel: ObservableObject {
    private let firestoreService = FirestoreService()

    @Published var tasks: [Clothingitem] = []

    private var cancellables: Set<AnyCancellable> = []


     func addItem(newItem: Clothingitem) {
        let newItem = newItem
        firestoreService.addDocument(collection: "UserFeedback", data: newItem)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error adding task: \(error.localizedDescription)")
                }
            }, receiveValue: { _ in
//                self.loadTasks()
            })
            .store(in: &cancellables)
    }

}

import RealmSwift
import SwiftUI

class Clothingitem: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var itemImage = ""
    @Persisted var itemDescription = ""
    @Persisted var colors = RealmSwift.List<String>()
        
}

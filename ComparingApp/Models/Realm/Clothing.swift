import RealmSwift
import SwiftUI

class Clothingitem: Object, ObjectKeyIdentifiable, Codable {
    
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var itemImage = ""
    @Persisted var itemDescription = ""
    @Persisted var itemFeedback = ""
    @Persisted var colors = RealmSwift.List<String>()
        
    static func defineMigrationBlock() {
         let config = Realm.Configuration(
             schemaVersion: 2, // Increment the schema version to trigger migration
             migrationBlock: { migration, oldSchemaVersion in
                 if oldSchemaVersion < 2 {
                     // Perform migration steps here
                     migration.enumerateObjects(ofType: Clothingitem.className()) { oldObject, newObject in
                         // Set a default value for the new property
                         newObject?["itemFeedback"] = ""
                     }
                 }
             }
         )
         Realm.Configuration.defaultConfiguration = config
     }
}

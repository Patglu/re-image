import SwiftUI
import FirebaseCore
import RealmSwift

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      Clothingitem.defineMigrationBlock()
    FirebaseApp.configure()
    return true
  }
}

@main
struct ComparingAppApp: SwiftUI.App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                HomeView()
                    .environmentObject(ComparingClothesViewModel())
                    
            }
        }
    }
}
